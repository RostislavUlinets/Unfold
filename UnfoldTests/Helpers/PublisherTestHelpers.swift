import Foundation
import Combine

/// Helper utilities for testing Combine publishers and @Published properties
@MainActor
final class PublisherTestHelpers {

    /// Records published values from an ObservableObject
    final class ValueRecorder<T: Equatable> {
        private(set) var values: [T] = []
        private var cancellable: AnyCancellable?

        init() {}

        /// Starts recording values from a publisher
        func record<P: Publisher>(from publisher: P) where P.Output == T, P.Failure == Never {
            cancellable = publisher.sink { [weak self] value in
                self?.values.append(value)
            }
        }

        /// Returns the most recently recorded value
        var last: T? {
            values.last
        }

        /// Returns the first recorded value
        var first: T? {
            values.first
        }

        /// Returns the count of recorded values
        var count: Int {
            values.count
        }

        /// Checks if a specific value was recorded
        func contains(_ value: T) -> Bool {
            values.contains(value)
        }

        /// Clears all recorded values
        func reset() {
            values.removeAll()
        }

        /// Stops recording
        func stop() {
            cancellable?.cancel()
            cancellable = nil
        }
    }

    /// Waits for a @Published property to change to a specific value
    /// - Parameters:
    ///   - publisher: The publisher to monitor
    ///   - expectedValue: The value to wait for
    ///   - timeout: Maximum time to wait (default: 2 seconds)
    /// - Throws: If the expected value isn't published within the timeout
    static func waitForValue<T: Equatable>(
        from publisher: Published<T>.Publisher,
        toBe expectedValue: T,
        timeout: TimeInterval = 2.0
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for await value in publisher.values {
                    if value == expectedValue {
                        return
                    }
                }
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw PublisherTestError.timeout("Value \(expectedValue) not received within \(timeout) seconds")
            }

            try await group.next()
            group.cancelAll()
        }
    }

    /// Waits for a @Published property to satisfy a condition
    /// - Parameters:
    ///   - publisher: The publisher to monitor
    ///   - timeout: Maximum time to wait (default: 2 seconds)
    ///   - condition: The condition to check
    /// - Throws: If the condition isn't satisfied within the timeout
    static func waitForCondition<T>(
        from publisher: Published<T>.Publisher,
        timeout: TimeInterval = 2.0,
        condition: @escaping (T) -> Bool
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for await value in publisher.values {
                    if condition(value) {
                        return
                    }
                }
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw PublisherTestError.timeout("Condition not met within \(timeout) seconds")
            }

            try await group.next()
            group.cancelAll()
        }
    }

    /// Collects a specific number of published values
    /// - Parameters:
    ///   - publisher: The publisher to monitor
    ///   - count: Number of values to collect
    ///   - timeout: Maximum time to wait (default: 2 seconds)
    /// - Returns: Array of collected values
    /// - Throws: If the expected number of values aren't published within the timeout
    static func collect<T>(
        from publisher: Published<T>.Publisher,
        count expectedCount: Int,
        timeout: TimeInterval = 2.0
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: [T].self) { group in
            group.addTask {
                var collected: [T] = []
                for await value in publisher.values {
                    collected.append(value)
                    if collected.count == expectedCount {
                        return collected
                    }
                }
                return collected
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw PublisherTestError.timeout("Only collected values before timeout")
            }

            guard let result = try await group.next() else {
                throw PublisherTestError.unknown("Task group returned no result")
            }

            group.cancelAll()
            return result
        }
    }
}

// MARK: - Publisher Test Errors

enum PublisherTestError: Error, LocalizedError {
    case timeout(String)
    case valueMismatch(expected: Any, actual: Any)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .timeout(let message):
            return "Timeout: \(message)"
        case .valueMismatch(let expected, let actual):
            return "Value mismatch: expected \(expected), got \(actual)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
