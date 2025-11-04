import Foundation
import CoreLocation

/// Mock CLLocationManager for testing location-based functionality
final class MockCLLocationManager: CLLocationManager {

    // MARK: - Mock Configuration

    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var mockLocations: [CLLocation] = []
    var mockError: Error?
    var shouldTriggerLocationUpdate = true
    var shouldTriggerAuthChange = true

    // MARK: - Call Tracking

    private(set) var requestWhenInUseAuthorizationCalled = false
    private(set) var startUpdatingLocationCalled = false
    private(set) var stopUpdatingLocationCalled = false

    // MARK: - Delegate Storage

    weak var mockDelegate: CLLocationManagerDelegate?

    // MARK: - Overrides

    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }

    override var delegate: CLLocationManagerDelegate? {
        get { mockDelegate }
        set { mockDelegate = newValue }
    }

    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true

        if shouldTriggerAuthChange {
            // Simulate authorization status change
            mockAuthorizationStatus = .authorizedWhenInUse
            triggerAuthorizationChange()
        }
    }

    override func startUpdatingLocation() {
        startUpdatingLocationCalled = true

        if shouldTriggerLocationUpdate {
            // Simulate location updates
            if let error = mockError {
                triggerLocationError(error)
            } else if !mockLocations.isEmpty {
                triggerLocationUpdate(mockLocations)
            }
        }
    }

    override func stopUpdatingLocation() {
        stopUpdatingLocationCalled = true
    }

    // MARK: - Mock Trigger Methods

    /// Triggers a location update with the configured mock locations
    func triggerLocationUpdate(_ locations: [CLLocation]) {
        mockDelegate?.locationManager?(self, didUpdateLocations: locations)
    }

    /// Triggers a location error
    func triggerLocationError(_ error: Error) {
        mockDelegate?.locationManager?(self, didFailWithError: error)
    }

    /// Triggers an authorization status change
    func triggerAuthorizationChange() {
        mockDelegate?.locationManagerDidChangeAuthorization?(self)
    }

    /// Simulates authorization being granted
    func simulateAuthorizationGranted() {
        mockAuthorizationStatus = .authorizedWhenInUse
        triggerAuthorizationChange()
    }

    /// Simulates authorization being denied
    func simulateAuthorizationDenied() {
        mockAuthorizationStatus = .denied
        triggerAuthorizationChange()
    }

    /// Simulates authorization being restricted
    func simulateAuthorizationRestricted() {
        mockAuthorizationStatus = .restricted
        triggerAuthorizationChange()
    }

    // MARK: - Helper Methods

    /// Creates a mock location at the specified coordinates
    static func createMockLocation(
        latitude: Double,
        longitude: Double,
        altitude: Double = 0,
        horizontalAccuracy: Double = 10,
        verticalAccuracy: Double = 10,
        timestamp: Date = Date()
    ) -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            timestamp: timestamp
        )
    }

    // MARK: - Reset Methods

    func reset() {
        mockAuthorizationStatus = .notDetermined
        mockLocations = []
        mockError = nil
        shouldTriggerLocationUpdate = true
        shouldTriggerAuthChange = true

        requestWhenInUseAuthorizationCalled = false
        startUpdatingLocationCalled = false
        stopUpdatingLocationCalled = false
    }
}

// MARK: - Mock Location Errors

enum MockLocationError: Error, LocalizedError {
    case locationUnavailable
    case denied
    case timeout
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            return "Location services are unavailable"
        case .denied:
            return "Location access was denied"
        case .timeout:
            return "Location request timed out"
        case .custom(let message):
            return message
        }
    }
}
