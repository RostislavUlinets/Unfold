import SwiftUI

struct AuthHeaderView: View {
    @Binding var selectedMode: AuthMode

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            tabButton(for: .login)
            Spacer()
            tabButton(for: .signup)
            Spacer()
        }
    }

    private func tabButton(for mode: AuthMode) -> some View {
        VStack(spacing: 8) {
            Button {
                selectedMode = mode
            } label: {
                Text(mode == .login ? "Login" : "Sign Up")
                    .font(.headline)
                    .foregroundColor(.authBackground)
            }

            Rectangle()
                .fill(selectedMode == mode ? Color.authBackground : Color.clear)
                .frame(height: 2)
                .padding(.horizontal)
        }
        .animation(.smooth(duration: 0.2), value: selectedMode)
    }
}
