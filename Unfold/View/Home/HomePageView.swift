import SwiftUI

struct HomePageView: View {
    @EnvironmentObject private var auth: AuthController
    @State private var showSideMenu = false
    @State private var selectedTab: TabItem = .home
    @State private var exploredPercentage: Double = 12

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
            MapPlaceholder()

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
}
