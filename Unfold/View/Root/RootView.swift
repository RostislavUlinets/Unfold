import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthController
    @State private var showContent = false
    @State private var minimumDelayPassed = false

    var body: some View {
        ZStack {
            Color.authBackground
                .ignoresSafeArea()

            Group {
                if !showContent {
                    SplashView()
                        .transition(.opacity.combined(with: .scale))
                } else if auth.isAuthenticated {
                    HomeView()
                        .transition(.opacity.combined(with: .scale))
                } else {
                    AuthPageView()
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showContent)
            .animation(.easeInOut(duration: 0.4), value: auth.isAuthenticated)
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            minimumDelayPassed = true
            updateShowContentIfReady()
        }
        .onChange(of: auth.isLoading) { _ in
            updateShowContentIfReady()
        }
    }

    private func updateShowContentIfReady() {
        if minimumDelayPassed && !auth.isLoading {
            withAnimation {
                showContent = true
            }
        }
    }
}
