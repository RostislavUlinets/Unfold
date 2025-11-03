import SwiftUI

struct AuthFormView: View {
    @EnvironmentObject private var controller: AuthController
    @Binding var selectedMode: AuthMode

    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var showReset = false

    let parentSize: CGSize

    var body: some View {
        VStack(spacing: 20) {
            inputFields

            AuthSubmitButton(
                selectedMode: selectedMode,
                isLoading: controller.isLoading,
                action: handleAuth
            )
            .frame(width: parentSize.width * 0.85)
            .padding(.horizontal)
            .padding(.top, 10)

            if let error = controller.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            AuthFormFooter(
                selectedMode: selectedMode,
                authController: controller,
                showReset: $showReset
            )

            SocialLoginSection(
                onGoogleSignIn: handleGoogleSignIn,
                onAppleSignIn: handleAppleSignIn
            )
        }
        .padding(.bottom, 20)
        .animation(.smooth(duration: 0.2), value: selectedMode)
    }

    private var inputFields: some View {
        VStack(spacing: 16) {
            InputFieldView(
                label: "Email",
                text: $email,
                placeholder: "Email address",
                icon: AppIcons.email,
                keyboardType: .emailAddress
            )
            .padding(.horizontal)

            SecureInputFieldView(
                label: "Password",
                text: $password,
                placeholder: "Password",
                icon: AppIcons.lock
            )
            .padding(.horizontal)

            if selectedMode == .signup {
                SecureInputFieldView(
                    label: "Confirm Password",
                    text: $passwordConfirmation,
                    placeholder: "Re-enter password",
                    icon: AppIcons.lock
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func handleAuth() {
        Task {
            if selectedMode == .login {
                await controller.login(email: email, password: password)
            } else {
                await controller.signup(
                    email: email,
                    password: password,
                    verifyPassword: passwordConfirmation
                )
            }
        }
    }

    private func handleGoogleSignIn() {
        Task {
            await controller.signInWithGoogle()
        }
    }

    private func handleAppleSignIn() {
        Task {
            await controller.signInWithApple()
        }
    }
}
