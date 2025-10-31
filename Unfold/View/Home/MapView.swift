import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapController: MapController
    @EnvironmentObject var locationController: LocationController

    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .ignoresSafeArea()
            .onChange(of: locationController.currentLocation?.latitude) { _ in
                checkExplorationIfNeeded()
            }
            .onChange(of: locationController.currentLocation?.longitude) { _ in
                checkExplorationIfNeeded()
            }
    }

    private func checkExplorationIfNeeded() {
        guard let location = locationController.currentLocation else { return }
        mapController.checkExploration(at: location)
    }
}
