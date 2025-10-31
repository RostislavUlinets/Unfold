import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapController: MapController
    @EnvironmentObject var locationController: LocationController

    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: mapController.fogCells) { cell in
            MapAnnotation(coordinate: cell.coordinate) {
                FogCellView(cell: cell)
                    .environmentObject(mapController)
            }
        }
        .ignoresSafeArea()
        .onChange(of: region.center.latitude) { _ in
            mapController.updateFogCellsThrottled(for: region)
        }
        .onChange(of: region.center.longitude) { _ in
            mapController.updateFogCellsThrottled(for: region)
        }
        .onChange(of: region.span.latitudeDelta) { _ in
            mapController.updateFogCellsThrottled(for: region)
        }
        .onChange(of: locationController.currentLocation?.latitude) { _ in
            checkExplorationIfNeeded()
        }
        .onChange(of: locationController.currentLocation?.longitude) { _ in
            checkExplorationIfNeeded()
        }
        .onAppear {
            mapController.updateFogCells(for: region)
        }
    }

    private func checkExplorationIfNeeded() {
        guard let location = locationController.currentLocation else { return }
        mapController.checkExploration(at: location)
    }
}
