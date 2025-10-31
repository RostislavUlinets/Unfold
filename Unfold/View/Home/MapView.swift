import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapController: MapController
    @EnvironmentObject var locationController: LocationController

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .ignoresSafeArea()
            .onChange(of: locationController.currentLocation?.latitude) { _ in
                updateLocationIfNeeded()
            }
            .onChange(of: locationController.currentLocation?.longitude) { _ in
                updateLocationIfNeeded()
            }
            .onAppear {
                if let location = locationController.currentLocation {
                    region.center = location
                }
                locationController.requestLocationPermission()
            }
    }

    private func updateLocationIfNeeded() {
        guard let location = locationController.currentLocation else { return }
        region.center = location
        mapController.checkExploration(at: location)
    }
}
