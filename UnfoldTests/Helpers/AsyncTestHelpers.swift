import Foundation
import Testing

/// Helper utilities for testing async/await code
struct AsyncTestHelpers {

    /// Waits for an async condition to become true within a timeout period
    /// - Parameters:
    ///   - timeout: Maximum time to wait (default: 2 seconds)
    ///   - pollingInterval: How often to check the condition (default: 0.1 seconds)
    ///   - condition: The condition to wait for
    /// - Throws: If the condition doesn't become true within the timeout
    @MainActor
    static func waitForCondition(
        timeout: TimeInterval = 2.0,
        pollingInterval: TimeInterval = 0.1,
        condition: @escaping () -> Bool
    ) async throws {
        let startTime = Date()

        while !condition() {
            if Date().timeIntervalSince(startTime) > timeout {
                throw AsyncTestError.timeout("Condition not met within \(timeout) seconds")
            }

            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
        }
    }

    /// Waits for a specific amount of time
    /// - Parameter duration: Duration to wait in seconds
    @MainActor
    static func wait(duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }

    /// Waits for an async operation to complete and returns its result
    /// - Parameters:
    ///   - timeout: Maximum time to wait (default: 2 seconds)
    ///   - operation: The async operation to perform
    /// - Returns: The result of the operation
    /// - Throws: If the operation times out or throws an error
    @MainActor
    static func awaitWithTimeout<T>(
        timeout: TimeInterval = 2.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw AsyncTestError.timeout("Operation timed out after \(timeout) seconds")
            }

            guard let result = try await group.next() else {
                throw AsyncTestError.unknown("Task group returned no result")
            }

            group.cancelAll()
            return result
        }
    }

    /// Verifies that an async operation completes within a specific timeframe
    /// - Parameters:
    ///   - expectedDuration: Expected duration in seconds
    ///   - tolerance: Acceptable variance in seconds (default: 0.1)
    ///   - operation: The async operation to time
    /// - Throws: If the operation duration is outside the expected range
    @MainActor
    static func assertDuration(
        expectedDuration: TimeInterval,
        tolerance: TimeInterval = 0.1,
        operation: () async throws -> Void
    ) async throws {
        let startTime = Date()
        try await operation()
        let duration = Date().timeIntervalSince(startTime)

        let minDuration = expectedDuration - tolerance
        let maxDuration = expectedDuration + tolerance

        guard duration >= minDuration && duration <= maxDuration else {
            throw AsyncTestError.durationMismatch(
                expected: expectedDuration,
                actual: duration,
                tolerance: tolerance
            )
        }
    }
}

// MARK: - Async Test Errors

enum AsyncTestError: Error, LocalizedError {
    case timeout(String)
    case durationMismatch(expected: TimeInterval, actual: TimeInterval, tolerance: TimeInterval)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .timeout(let message):
            return "Timeout: \(message)"
        case .durationMismatch(let expected, let actual, let tolerance):
            return "Duration mismatch: expected \(expected)±\(tolerance)s, got \(actual)s"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
