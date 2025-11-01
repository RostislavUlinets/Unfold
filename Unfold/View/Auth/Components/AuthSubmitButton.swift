import SwiftUI

struct AuthSubmitButton: View {

    let selectedMode: AuthMode
    let isLoading: Bool
    let action: () -> Void


    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(selectedMode == .login ? "Sign In" : "Sign Up")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .foregroundColor(.white)
        .background(Color.authBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .disabled(isLoading)
    }
}


#Preview {
    VStack(spacing: 20) {
        AuthSubmitButton(selectedMode: .login, isLoading: false, action: {})
        AuthSubmitButton(selectedMode: .signup, isLoading: false, action: {})
        AuthSubmitButton(selectedMode: .login, isLoading: true, action: {})
    }
    .padding()
}
