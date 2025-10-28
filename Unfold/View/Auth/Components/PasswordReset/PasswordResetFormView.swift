import SwiftUI

struct PasswordResetFormView: View {
    @Binding var email: String
    @Binding var isEmailValid: Bool
    @FocusState.Binding var isEmailFieldFocused: Bool

    let isSending: Bool
    let errorMessage: String?
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            descriptionText

            EmailInputFieldWithValidation(
                email: $email,
                isEmailValid: $isEmailValid,
                isEmailFieldFocused: $isEmailFieldFocused,
                onSubmit: onSubmit
            )

            if let error = errorMessage {
                ErrorMessageView(message: error)
                    .padding(.horizontal, AppSpacing.xl)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()

            PasswordResetActionButtons(
                email: email,
                isSending: isSending,
                onSubmit: onSubmit,
                onCancel: onCancel
            )
        }
        .frame(height: 400)
    }

    private var descriptionText: some View {
        Text(Strings.Auth.resetDescription)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, AppSpacing.md)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var email = ""
        @State private var isEmailValid = true
        @FocusState private var isEmailFieldFocused: Bool

        var body: some View {
            PasswordResetFormView(
                email: $email,
                isEmailValid: $isEmailValid,
                isEmailFieldFocused: $isEmailFieldFocused,
                isSending: false,
                errorMessage: nil,
                onSubmit: {},
                onCancel: {}
            )
        }
    }

    return PreviewWrapper()
        .background(Color.white)
}
