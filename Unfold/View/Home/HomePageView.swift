import SwiftUI
import MapKit

struct HomePageView: View {
    @EnvironmentObject private var auth: AuthController
    @EnvironmentObject private var mapController: MapController
    @EnvironmentObject private var locationController: LocationController
    @State private var showSideMenu = false
    @State private var selectedTab: TabItem = .home
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    private var exploredPercentage: Double {
        mapController.explorationStats.explorationPercentage
    }

    var body: some View {
        ZStack {
            mainContent

            SideMenuView(isShowing: $showSideMenu)
                .environmentObject(auth)
        }
        .ignoresSafeArea()
    }

    private var mainContent: some View {
        ZStack {
            MapView(region: $mapRegion)
                .environmentObject(mapController)
                .environmentObject(locationController)

            VStack {
                TopControlsBar(
                    showSideMenu: $showSideMenu,
                    mapRegion: $mapRegion,
                    exploredPercentage: exploredPercentage,
                    onLocationTapped: handleLocationButtonTap
                )
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    zoomControls
                        .padding(.trailing, 16)
                        .padding(.bottom, 120)
                }
            }

            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: $selectedTab)
            }
        }
    }


    private var zoomControls: some View {
        VStack(spacing: 12) {
            ControlButton(icon: "plus") {
                zoomIn()
            }
            ControlButton(icon: "minus") {
                zoomOut()
            }
        }
    }

    private func handleLocationButtonTap() {
        locationController.startTracking()
        if let location = locationController.currentLocation {
            withAnimation {
                mapRegion.center = location
            }
        }
    }

    private func zoomIn() {
        withAnimation {
            mapRegion.span.latitudeDelta /= 2
            mapRegion.span.longitudeDelta /= 2
        }
    }

    private func zoomOut() {
        withAnimation {
            mapRegion.span.latitudeDelta *= 2
            mapRegion.span.longitudeDelta *= 2
        }
    }
}

#Preview {
    HomePageView()
        .environmentObject(AuthController.createDefault())
        .environmentObject(MapController())
        .environmentObject(LocationController())
}
