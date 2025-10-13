import SwiftUI

struct AuthFormView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""

    @Binding var selectedMode: AuthMode

    @EnvironmentObject var controller: AuthController

    let parentSize: CGSize

    var body: some View {
        VStack {

            Text("Email")
                .font(.headline)
                .foregroundColor(.authBackground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.authBackground, lineWidth: 1)
                )
                .padding(.horizontal)

            Text("Password")
                .font(.headline)
                .foregroundColor(.authBackground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.authBackground, lineWidth: 1)
                )
                .padding(.horizontal)

            if selectedMode == AuthMode.signup {

                Text("Confirm Password")
                    .font(.headline)
                    .foregroundColor(.authBackground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                SecureField("Re-enter password", text: $passwordConfirmation)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.authBackground, lineWidth: 1)
                    )
                    .padding(.horizontal)

            }

            Button(action: {
                Task {
                    if selectedMode == .login {
                        await controller.login(email: email, password: password)
                    } else {
                        await  controller.signup(
                            email: email,
                            password: password,
                            verifyPassword: passwordConfirmation
                        )
                    }
                }
                
                
            }) {
                if controller.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.authBackground)
                        .cornerRadius(24)
                } else {
                    Text(selectedMode == .login ? "Login" : "Sign Up")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.authBackground)
                        .cornerRadius(24)
                }
            }
            .frame(width: parentSize.width * 0.6, height: 55)
            .padding(.horizontal)
            .padding(.top, 10)

            if let error = controller.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }

            VStack(spacing: 4) {
                Text(
                    selectedMode == .login
                        ? "Don't have an account?"
                        : "Already have an account?"
                )
                .font(.footnote)
                .foregroundColor(.authBackground)
                .padding(.bottom, 30)

                Text("Terms & Conditions")
                    .font(.caption)
                    .foregroundColor(.authBackground)
                    .underline()
            }
            .padding(.top, 10)

        }
        .padding(.bottom, 20)
    }
}
