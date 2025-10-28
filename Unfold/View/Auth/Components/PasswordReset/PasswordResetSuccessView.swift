import SwiftUI

struct PasswordResetSuccessView: View {

    let email: String
    let onDone: () -> Void


    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            successIcon

            messageSection

            hintText

            Spacer()

            Button(Strings.Common.done, action: onDone)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xl)
        }
        .frame(height: 400)
    }


    private var successIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.success.opacity(0.1))
                .frame(width: 100, height: 100)

            Image(systemName: AppIcons.success)
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(AppColors.success)
        }
    }

    private var messageSection: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(Strings.Auth.resetEmailSent)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.authBackground)

            Text(Strings.Auth.resetInstructions)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(email)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.authBackground)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, AppSpacing.xxl)
    }

    private var hintText: some View {
        Text(Strings.Auth.resetHint)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppSpacing.xxl)
            .padding(.top, AppSpacing.xs)
    }
}


#Preview {
    PasswordResetSuccessView(
        email: "user@example.com",
        onDone: {}
    )
    .background(Color.white)
}
