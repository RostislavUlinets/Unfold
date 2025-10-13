import SwiftUI

enum AuthMode {
    case login
    case signup
}

struct AuthPageView: View {
    @State var authMode: AuthMode = .login

    @StateObject private var controller = AuthController()

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

                    VStack(spacing: 40) {
                        AuthHeaderView(selectedMode: $authMode)
                        AuthFormView(
                            selectedMode: $authMode,
                            parentSize: geometry.size
                        ).environmentObject(controller)
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.white
                            .clipShape(
                                RoundedCorner(
                                    radius: 32,
                                    corners: [.topLeft, .topRight]
                                )
                            )
                    )

                }
                .ignoresSafeArea(edges: .bottom)
                .animation(.easeInOut(duration: 0.3), value: authMode)
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 25.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}

#Preview {
    AuthPageView().environmentObject(AuthController())
}
