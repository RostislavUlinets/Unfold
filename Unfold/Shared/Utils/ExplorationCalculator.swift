import Foundation

struct ExplorationCalculator {
    private static let estimatedTotalCells: Double = 10_000.0
    private static let metersPerCell: Double = 50.0
    private static let kilometersPerCell: Double = 0.05

    static func calculatePercentage(exploredCells: Int) -> Double {
        guard exploredCells > 0 else { return 0.0 }
        let percentage = (Double(exploredCells) / estimatedTotalCells) * 100.0
        return min(percentage, 100.0)
    }

    static func estimateDistance(from cells: Set<String>) -> Double {
        return Double(cells.count) * kilometersPerCell
    }
}
