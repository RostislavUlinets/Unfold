import Testing
import Foundation
import CoreLocation
@testable import Unfold

/// Tests for LocationController
/// Note: These tests focus on state management and observable properties.
/// Full testing of CLLocationManager interactions would require mocking.
@Suite("LocationController Tests")
@MainActor
struct LocationControllerTests {

    // MARK: - Initialization Tests

    @Test("LocationController initializes with correct default state")
    func initialization_hasCorrectDefaultState() {
        // Arrange & Act
        let controller = LocationController()

        // Assert
        #expect(controller.currentLocation == nil)
        #expect(controller.isTrackingLocation == false)
        #expect(controller.locationError == nil)
    }

    // MARK: - State Management Tests

    @Test("currentLocation can be set and read")
    func currentLocation_canBeSetAndRead() {
        // Arrange
        let controller = LocationController()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // Act
        controller.currentLocation = coordinate

        // Assert
        #expect(controller.currentLocation != nil)
        #expect(controller.currentLocation?.latitude == 37.7749)
        #expect(controller.currentLocation?.longitude == -122.4194)
    }

    @Test("currentLocation can be cleared")
    func currentLocation_canBeCleared() {
        // Arrange
        let controller = LocationController()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        controller.currentLocation = coordinate

        // Act
        controller.currentLocation = nil

        // Assert
        #expect(controller.currentLocation == nil)
    }

    @Test("isTrackingLocation can be toggled")
    func isTrackingLocation_canBeToggled() {
        // Arrange
        let controller = LocationController()
        #expect(controller.isTrackingLocation == false)

        // Act
        controller.isTrackingLocation = true

        // Assert
        #expect(controller.isTrackingLocation == true)

        // Act
        controller.isTrackingLocation = false

        // Assert
        #expect(controller.isTrackingLocation == false)
    }

    @Test("locationError can be set and read")
    func locationError_canBeSetAndRead() {
        // Arrange
        let controller = LocationController()

        // Act
        controller.locationError = "Location services disabled"

        // Assert
        #expect(controller.locationError == "Location services disabled")
    }

    @Test("locationError can be cleared")
    func locationError_canBeCleared() {
        // Arrange
        let controller = LocationController()
        controller.locationError = "Some error"

        // Act
        controller.locationError = nil

        // Assert
        #expect(controller.locationError == nil)
    }

    // MARK: - Authorization Status Tests

    @Test("authorizationStatus initializes with a value")
    func authorizationStatus_initializesWithValue() {
        // Arrange & Act
        let controller = LocationController()

        // Assert - Should be initialized (actual value depends on system/simulator state)
        let status = controller.authorizationStatus
        #expect(status == .notDetermined || status == .authorizedWhenInUse ||
                status == .authorizedAlways || status == .denied || status == .restricted)
    }

    // MARK: - Multiple Location Updates Tests

    @Test("multiple location updates can be tracked")
    func multipleLocationUpdates_canBeTracked() {
        // Arrange
        let controller = LocationController()
        let locations = [
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4195),
            CLLocationCoordinate2D(latitude: 37.7751, longitude: -122.4196)
        ]

        // Act & Assert - Update location multiple times
        for location in locations {
            controller.currentLocation = location
            #expect(controller.currentLocation?.latitude == location.latitude)
            #expect(controller.currentLocation?.longitude == location.longitude)
        }
    }

    // MARK: - Error State Tests

    @Test("error and location can coexist")
    func errorAndLocation_canCoexist() {
        // Arrange
        let controller = LocationController()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // Act
        controller.currentLocation = coordinate
        controller.locationError = "Minor warning"

        // Assert
        #expect(controller.currentLocation != nil)
        #expect(controller.locationError != nil)
    }

    @Test("clearing error does not affect location")
    func clearingError_doesNotAffectLocation() {
        // Arrange
        let controller = LocationController()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        controller.currentLocation = coordinate
        controller.locationError = "Some error"

        // Act
        controller.locationError = nil

        // Assert
        #expect(controller.currentLocation != nil)
        #expect(controller.currentLocation?.latitude == 37.7749)
    }

    @Test("clearing location does not affect error")
    func clearingLocation_doesNotAffectError() {
        // Arrange
        let controller = LocationController()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        controller.currentLocation = coordinate
        controller.locationError = "Some error"

        // Act
        controller.currentLocation = nil

        // Assert
        #expect(controller.locationError == "Some error")
        #expect(controller.currentLocation == nil)
    }

    // MARK: - Tracking State Tests

    @Test("tracking state independent of location")
    func trackingState_independentOfLocation() {
        // Arrange
        let controller = LocationController()

        // Act - Set tracking without location
        controller.isTrackingLocation = true

        // Assert
        #expect(controller.isTrackingLocation == true)
        #expect(controller.currentLocation == nil)
    }

    @Test("location can exist without tracking")
    func location_canExistWithoutTracking() {
        // Arrange
        let controller = LocationController()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // Act
        controller.currentLocation = coordinate

        // Assert
        #expect(controller.currentLocation != nil)
        #expect(controller.isTrackingLocation == false)
    }

    // MARK: - Edge Case Tests

    @Test("extreme latitude and longitude values are handled")
    func extremeCoordinates_areHandled() {
        // Arrange
        let controller = LocationController()

        // Act - North pole
        controller.currentLocation = CLLocationCoordinate2D(latitude: 90.0, longitude: 0.0)
        #expect(controller.currentLocation?.latitude == 90.0)

        // Act - South pole
        controller.currentLocation = CLLocationCoordinate2D(latitude: -90.0, longitude: 0.0)
        #expect(controller.currentLocation?.latitude == -90.0)

        // Act - Date line
        controller.currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 180.0)
        #expect(controller.currentLocation?.longitude == 180.0)

        // Act - Date line (negative)
        controller.currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: -180.0)
        #expect(controller.currentLocation?.longitude == -180.0)
    }

    @Test("very long error messages are handled")
    func veryLongErrorMessage_isHandled() {
        // Arrange
        let controller = LocationController()
        let longError = String(repeating: "Error ", count: 100)

        // Act
        controller.locationError = longError

        // Assert
        #expect(controller.locationError == longError)
    }

    @Test("special characters in error message are handled")
    func specialCharactersInError_areHandled() {
        // Arrange
        let controller = LocationController()
        let specialError = "Error: Location unavailable! (Code: 123) — Try again…"

        // Act
        controller.locationError = specialError

        // Assert
        #expect(controller.locationError == specialError)
    }

    // MARK: - State Reset Tests

    @Test("all state can be reset")
    func allState_canBeReset() {
        // Arrange
        let controller = LocationController()
        controller.currentLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        controller.isTrackingLocation = true
        controller.locationError = "Some error"

        // Act - Reset all state
        controller.currentLocation = nil
        controller.isTrackingLocation = false
        controller.locationError = nil

        // Assert
        #expect(controller.currentLocation == nil)
        #expect(controller.isTrackingLocation == false)
        #expect(controller.locationError == nil)
    }
}
