import Foundation
import CoreLocation
import Combine

@MainActor
final class MapController: ObservableObject {
    @Published var exploredCells: Set<String> = []
    @Published var explorationStats: ExplorationStats = .empty
    @Published var fogCells: [GridCell] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?

    private var exploredCellsData: [ExploredCell] = []
    private var cancellables = Set<AnyCancellable>()

    private let userDefaultsKey = "explored_cells"
    private let statsDefaultsKey = "exploration_stats"
    private let lastSyncKey = "last_sync_date"

    init() {
        loadFromPersistence()
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

        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }

    // MARK: - Future Sync

    func syncToSupabase() async {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncDate = Date()
        saveToPersistence()
    }
}
