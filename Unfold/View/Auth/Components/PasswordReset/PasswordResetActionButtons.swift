import SwiftUI

struct PasswordResetActionButtons: View {

    let email: String
    let isSending: Bool
    let onSubmit: () -> Void
    let onCancel: () -> Void


    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Button(action: onSubmit) {
                if isSending {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Label(Strings.Auth.sendResetLink, systemImage: AppIcons.email)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: email.isEmpty || isSending))
            .disabled(email.isEmpty || isSending)
            .accessibilityLabel(Strings.Auth.sendResetLink)

            Button(Strings.Common.cancel, action: onCancel)
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityLabel("Cancel password reset")
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.bottom, AppSpacing.xl)
    }
}


#Preview {
    PasswordResetActionButtons(
        email: "test@example.com",
        isSending: false,
        onSubmit: {},
        onCancel: {}
    )
    .background(Color.white)
}
