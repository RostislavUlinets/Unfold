import SwiftUI

struct HomePageView: View {
    @EnvironmentObject private var auth: AuthController
    @EnvironmentObject private var mapController: MapController
    @EnvironmentObject private var locationController: LocationController
    @State private var showSideMenu = false
    @State private var selectedTab: TabItem = .home

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
            MapView()
                .environmentObject(mapController)
                .environmentObject(locationController)

            VStack {
                TopControlsBar(
                    showSideMenu: $showSideMenu,
                    exploredPercentage: exploredPercentage
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
            ControlButton(icon: "plus") {}
            ControlButton(icon: "minus") {}
        }
    }
}

#Preview {
    HomePageView()
        .environmentObject(AuthController.createDefault())
        .environmentObject(MapController())
        .environmentObject(LocationController())
}
