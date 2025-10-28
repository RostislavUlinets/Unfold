import SwiftUI

enum AuthMode {
    case login, signup
}

struct AuthPageView: View {
    @EnvironmentObject private var controller: AuthController
    @State private var authMode: AuthMode = .login

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.authBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    Text("Hello & Welcome!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 40)

                    Spacer()

                    authFormContainer(parentSize: geometry.size)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(.smooth(duration: 0.3), value: authMode)
    }

    private func authFormContainer(parentSize: CGSize) -> some View {
        VStack(spacing: 40) {
            AuthHeaderView(selectedMode: $authMode)
            AuthFormView(selectedMode: $authMode, parentSize: parentSize)
                .environmentObject(controller)
        }
        .padding(.top)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                .fill(Color.white)
        )
    }
}
