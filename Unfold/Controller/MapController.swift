import Foundation
import CoreLocation
import MapKit
import Combine
import Supabase

@MainActor
final class MapController: ObservableObject {
    @Published var exploredCells: Set<String> = []
    @Published var explorationStats: ExplorationStats = .empty
    @Published var fogCells: [GridCell] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?

    private var exploredCellsData: [ExploredCell] = []
    private var syncedCellIds: Set<String> = []
    private var cancellables = Set<AnyCancellable>()
    private var syncTimer: Timer?
    private var fogUpdateWorkItem: DispatchWorkItem?

    private let userDefaultsKey = "explored_cells"
    private let statsDefaultsKey = "exploration_stats"
    private let lastSyncKey = "last_sync_date"
    private let syncedCellsKey = "synced_cells"

    private weak var authController: AuthController?

    init(authController: AuthController? = nil) {
        self.authController = authController
        loadFromPersistence()
        setupPeriodicSync()
    }

    deinit {
        syncTimer?.invalidate()
    }

    // MARK: - Dependency Injection

    func setAuthController(_ controller: AuthController) {
        self.authController = controller
    }

    // MARK: - Exploration Detection

    func checkExploration(at location: CLLocationCoordinate2D) {
        let cellsInRadius = calculateClearRadius(around: location)

        var newCellsDiscovered = false

        for cell in cellsInRadius {
            if !exploredCells.contains(cell.cellId) {
                markCellAsExplored(cell)
                newCellsDiscovered = true
            }
        }

        if newCellsDiscovered {
            updateExplorationStats()
            saveToPersistence()
        }
    }

    func calculateClearRadius(around location: CLLocationCoordinate2D) -> [GridCell] {
        return GridCalculator.cellsWithinRadius(center: location, radiusMeters: 150.0)
    }

    func updateFogCellsThrottled(for region: MKCoordinateRegion) {
        fogUpdateWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.updateFogCells(for: region)
        }

        fogUpdateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    func updateFogCells(for region: MKCoordinateRegion) {
        let maxCells = 150

        let centerLat = region.center.latitude
        let centerLng = region.center.longitude
        let latSpan = region.span.latitudeDelta
        let lngSpan = region.span.longitudeDelta

        let minLat = centerLat - latSpan / 2
        let maxLat = centerLat + latSpan / 2
        let minLng = centerLng - lngSpan / 2
        let maxLng = centerLng + lngSpan / 2

        let gridSize = GridCalculator.gridSize
        let gridDegrees = GridCalculator.metersToLatitudeDegrees(gridSize)

        // Calculate how many cells would be generated
        let latCellCount = Int(ceil((maxLat - minLat) / gridDegrees))
        let lngCellCount = Int(ceil((maxLng - minLng) / gridDegrees))
        let totalCells = latCellCount * lngCellCount

        // If too many cells, sample them to stay under limit
        let skipFactor = totalCells > maxCells ? Int(ceil(Double(totalCells) / Double(maxCells))) : 1

        var cells: [GridCell] = []
        var latIndex = 0
        var currentLat = minLat

        while currentLat <= maxLat && cells.count < maxCells {
            if latIndex % skipFactor == 0 {
                var lngIndex = 0
                var currentLng = minLng

                while currentLng <= maxLng && cells.count < maxCells {
                    if lngIndex % skipFactor == 0 {
                        let coordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLng)
                        let cell = GridCell(coordinate: coordinate)
                        cells.append(cell)
                    }
                    currentLng += gridDegrees
                    lngIndex += 1
                }
            }
            currentLat += gridDegrees
            latIndex += 1
        }

        fogCells = cells
    }

    // MARK: - Cell Management

    private func markCellAsExplored(_ cell: GridCell) {
        exploredCells.insert(cell.cellId)

        let exploredCell = ExploredCell(
            id: cell.cellId,
            latitude: cell.latitude,
            longitude: cell.longitude,
            exploredAt: Date()
        )
        exploredCellsData.append(exploredCell)
    }

    // MARK: - Statistics

    func updateExplorationStats() {
        let totalCells = exploredCells.count
        let percentage = ExplorationCalculator.calculatePercentage(exploredCells: totalCells)
        let distance = ExplorationCalculator.estimateDistance(from: exploredCells)

        explorationStats = ExplorationStats(
            totalCellsExplored: totalCells,
            explorationPercentage: percentage,
            totalDistanceTraveled: distance,
            lastUpdated: Date()
        )
    }

    // MARK: - Persistence

    func saveToPersistence() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let cellsData = try? encoder.encode(exploredCellsData) {
            UserDefaults.standard.set(cellsData, forKey: userDefaultsKey)
        }

        if let statsData = try? encoder.encode(explorationStats) {
            UserDefaults.standard.set(statsData, forKey: statsDefaultsKey)
        }

        if let lastSync = lastSyncDate {
            UserDefaults.standard.set(lastSync, forKey: lastSyncKey)
        }
    }

    func loadFromPersistence() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let cellsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let cells = try? decoder.decode([ExploredCell].self, from: cellsData) {
            exploredCellsData = cells
            exploredCells = Set(cells.map(\.id))
        }

        if let statsData = UserDefaults.standard.data(forKey: statsDefaultsKey),
           let stats = try? decoder.decode(ExplorationStats.self, from: statsData) {
            explorationStats = stats
        } else {
            explorationStats = .empty
        }

        if let syncedData = UserDefaults.standard.array(forKey: syncedCellsKey) as? [String] {
            syncedCellIds = Set(syncedData)
        }

        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }

    // MARK: - Sync

    private func setupPeriodicSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.syncToSupabase()
            }
        }
    }

    func syncToSupabase() async {
        guard let authController = authController,
              let userId = authController.currentUser?.id else {
            return
        }

        let client = authController.supabaseClient

        guard !isSyncing else { return }

        let cellsToSync = exploredCellsData.filter { !syncedCellIds.contains($0.id) }
        guard !cellsToSync.isEmpty else { return }

        isSyncing = true
        syncError = nil

        do {
            let formatter = ISO8601DateFormatter()
            let rows: [[String: AnyJSON]] = cellsToSync.map { cell in
                [
                    "user_id": AnyJSON.string(userId),
                    "cell_id": AnyJSON.string(cell.id),
                    "latitude": AnyJSON.double(cell.latitude),
                    "longitude": AnyJSON.double(cell.longitude),
                    "explored_at": AnyJSON.string(formatter.string(from: cell.exploredAt))
                ]
            }

            try await client.from("explored_cells").insert(rows).execute()

            syncedCellIds.formUnion(cellsToSync.map(\.id))
            lastSyncDate = Date()

            UserDefaults.standard.set(Array(syncedCellIds), forKey: syncedCellsKey)
            saveToPersistence()

        } catch {
            syncError = "Sync failed: \(error.localizedDescription)"
        }

        isSyncing = false
    }

    // MARK: - Data Management

    func clearData() {
        exploredCells.removeAll()
        exploredCellsData.removeAll()
        syncedCellIds.removeAll()
        explorationStats = .empty
        lastSyncDate = nil

        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: statsDefaultsKey)
        UserDefaults.standard.removeObject(forKey: syncedCellsKey)
        UserDefaults.standard.removeObject(forKey: lastSyncKey)
    }
}
