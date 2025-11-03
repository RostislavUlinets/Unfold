import SwiftUI

enum SocialLoginProvider {
    case google
    case apple

    var icon: String {
        switch self {
        case .google:
            return "g.circle.fill"
        case .apple:
            return "apple.logo"
        }
    }
}

struct SocialLoginButton: View {

    let provider: SocialLoginProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: provider.icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.authBackground)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.authBackground.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

#Preview {
    HStack(spacing: AppSpacing.lg) {
        SocialLoginButton(provider: .google, action: {})
        SocialLoginButton(provider: .apple, action: {})
    }
    .padding()
    .background(AppColors.authInputBackground)
}
