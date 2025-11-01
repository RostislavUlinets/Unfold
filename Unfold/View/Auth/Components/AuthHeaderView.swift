import SwiftUI

struct AuthHeaderView: View {
    @Binding var selectedMode: AuthMode

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            tabButton(for: .login)
            tabButton(for: .signup)
        }
        .padding(6)
        .background(AppColors.authInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
    }

    private func tabButton(for mode: AuthMode) -> some View {
        Button {
            selectedMode = mode
        } label: {
            Text(mode == .login ? "Login" : "Sign Up")
                .font(.headline)
                .foregroundColor(selectedMode == mode ? .white : AppColors.authBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(selectedMode == mode ? AppColors.authBackground : AppColors.authSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
        }
        .animation(.smooth(duration: 0.2), value: selectedMode)
    }
}
