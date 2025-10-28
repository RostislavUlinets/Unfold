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
            .frame(width: parentSize.width * 0.6, height: 55)
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
                authService: controller.authService,
                showReset: $showReset
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
                placeholder: "Email",
                keyboardType: .emailAddress
            )

            InputFieldView(
                label: "Password",
                text: $password,
                placeholder: "Password",
                isSecure: true
            )

            if selectedMode == .signup {
                InputFieldView(
                    label: "Confirm Password",
                    text: $passwordConfirmation,
                    placeholder: "Re-enter password",
                    isSecure: true
                )
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
}
