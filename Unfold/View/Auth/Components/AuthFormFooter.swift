import SwiftUI

struct AuthFormFooter: View {

    let selectedMode: AuthMode
    let authController: AuthController

    @Binding var showReset: Bool


    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            if selectedMode == .login {
                Button {
                    showReset = true
                } label: {
                    Text("Forgot your password?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.authBackground)
                }
                .popover(isPresented: $showReset, arrowEdge: .bottom) {
                    PasswordResetDialog(authController: authController)
                        .presentationCompactAdaptation(.none)
                }
                .transition(.opacity)
            }

            Group {
                Text("By continuing, you agree to our ")
                    .foregroundColor(AppColors.authBackground.opacity(0.8))
                +
                Text("Terms of Service")
                    .foregroundColor(AppColors.authBackground)
                    .fontWeight(.medium)
                    .underline()
                +
                Text(" and ")
                    .foregroundColor(AppColors.authBackground.opacity(0.8))
                +
                Text("Privacy Policy")
                    .foregroundColor(AppColors.authBackground)
                    .fontWeight(.medium)
                    .underline()
            }
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding(.top, AppSpacing.md)
    }
}


#Preview {
    AuthFormFooter(
        selectedMode: .login,
        authController: AuthController.createDefault(),
        showReset: .constant(false)
    )
}
