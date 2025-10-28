import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject private var auth: AuthController
    @Binding var isShowing: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.smooth(duration: 0.3)) {
                            isShowing = false
                        }
                    }
            }

            if isShowing {
                menuContent
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth(duration: 0.3), value: isShowing)
    }

    private var menuContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            UserProfileSection()
                .padding(.top, 60)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            Divider()
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                MenuItemView(icon: "person.fill", title: "Profile Settings")
                MenuItemView(icon: "bell.fill", title: "Notifications")
                MenuItemView(icon: "gearshape.fill", title: "Settings")
                MenuItemView(icon: "questionmark.circle.fill", title: "Help & Support")
            }
            .padding(.top, 16)

            Spacer()

            LogoutButton(action: handleLogout)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .frame(width: 280)
        .frame(maxHeight: .infinity)
        .background(Color.white)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 5, y: 0)
    }

    private func handleLogout() {
        Task {
            await auth.logout()
        }

        withAnimation(.smooth(duration: 0.3)) {
            isShowing = false
        }
    }
}

#Preview {
    SideMenuView(isShowing: .constant(true))
        .environmentObject(AuthController.createDefault())
}
