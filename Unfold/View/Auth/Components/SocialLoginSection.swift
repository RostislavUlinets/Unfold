import SwiftUI

struct SocialLoginSection: View {

    let onGoogleSignIn: () -> Void
    let onAppleSignIn: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                Rectangle()
                    .fill(AppColors.authBackground.opacity(0.2))
                    .frame(height: 1)

                Text("Or continue with")
                    .font(.caption)
                    .foregroundColor(AppColors.authBackground.opacity(0.6))
                    .padding(.horizontal, AppSpacing.sm)

                Rectangle()
                    .fill(AppColors.authBackground.opacity(0.2))
                    .frame(height: 1)
            }

            HStack(spacing: AppSpacing.xl) {
                SocialLoginButton(provider: .google, action: onGoogleSignIn)
                SocialLoginButton(provider: .apple, action: onAppleSignIn)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    SocialLoginSection(
        onGoogleSignIn: { print("Google sign in") },
        onAppleSignIn: { print("Apple sign in") }
    )
    .background(Color.white)
}
