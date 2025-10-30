import SwiftUI

struct AuthFormFooter: View {

    let selectedMode: AuthMode
    let authController: AuthController

    @Binding var showReset: Bool


    var body: some View {
        VStack(spacing: 8) {
            if selectedMode == .login {
                Button("Forgot Password?") {
                    showReset = true
                }
                .foregroundColor(.authBackground)
                .popover(isPresented: $showReset, arrowEdge: .bottom) {
                    PasswordResetDialog(authController: authController)
                        .presentationCompactAdaptation(.none)
                }
                .transition(.opacity)
            }

            Button("Terms & Conditions") {}
                .font(.caption)
                .foregroundColor(.authBackground)
        }
        .padding(.top, 10)
    }
}


#Preview {
    AuthFormFooter(
        selectedMode: .login,
        authController: AuthController.createDefault(),
        showReset: .constant(false)
    )
}
