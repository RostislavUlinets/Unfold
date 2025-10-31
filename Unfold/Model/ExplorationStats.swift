import Foundation

struct ExplorationStats: Codable {
    var totalCellsExplored: Int
    var explorationPercentage: Double
    var totalDistanceTraveled: Double
    var lastUpdated: Date

    static var empty: ExplorationStats {
        ExplorationStats(
            totalCellsExplored: 0,
            explorationPercentage: 0.0,
            totalDistanceTraveled: 0.0,
            lastUpdated: Date()
        )
    }
}

extension ExplorationStats {
    static var mock: ExplorationStats {
        ExplorationStats(
            totalCellsExplored: 42,
            explorationPercentage: 12.5,
            totalDistanceTraveled: 2.1,
            lastUpdated: Date()
        )
    }
}
