import Foundation
import CoreLocation

@MainActor
final class LocationController: NSObject, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTrackingLocation: Bool = false
    @Published var locationError: String?

    private let locationManager: CLLocationManager

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = "Location permission not granted. Please enable location access in Settings."
            return
        }

        locationManager.startUpdatingLocation()
        isTrackingLocation = true
        locationError = nil
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTrackingLocation = false
    }

    // MARK: - Private Methods

    private func handleLocationUpdate(_ location: CLLocation) {
        currentLocation = location.coordinate
        locationError = nil
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .notDetermined:
            locationError = nil
        case .restricted:
            locationError = "Location access is restricted. Please check your device settings."
            stopTracking()
        case .denied:
            locationError = "Location access denied. Please enable location access in Settings to use this feature."
            stopTracking()
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
        @unknown default:
            locationError = "Unknown location authorization status."
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationController: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            handleLocationUpdate(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationError = "Failed to get location: \(error.localizedDescription)"
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            handleAuthorizationStatus(manager.authorizationStatus)
        }
    }
}
