import SwiftUI

struct EmailInputFieldWithValidation: View {

    @Binding var email: String
    @Binding var isEmailValid: Bool
    @FocusState.Binding var isEmailFieldFocused: Bool

    let onSubmit: () -> Void


    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(Strings.Auth.email)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.authBackground)

            TextField("Enter your email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isEmailFieldFocused)
                .padding(AppSpacing.sm + 2)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .stroke(borderColor, lineWidth: isEmailFieldFocused ? 2 : 1)
                )
                .onSubmit(onSubmit)
                .accessibilityLabel(Strings.Auth.email)
                .accessibilityHint("Enter your email to receive password reset instructions")

            if !isEmailValid {
                Label(Strings.Auth.invalidEmail, systemImage: AppIcons.warning)
                    .font(.caption)
                    .foregroundColor(AppColors.error)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, AppSpacing.xl)
        .animation(.smooth(duration: AppAnimation.fast), value: isEmailValid)
    }


    private var borderColor: Color {
        if !isEmailValid {
            return AppColors.error
        }
        return isEmailFieldFocused ? AppColors.authBackground : Color(.systemGray4)
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var email = ""
        @State private var isEmailValid = true
        @FocusState private var isEmailFieldFocused: Bool

        var body: some View {
            EmailInputFieldWithValidation(
                email: $email,
                isEmailValid: $isEmailValid,
                isEmailFieldFocused: $isEmailFieldFocused,
                onSubmit: {}
            )
        }
    }

    return PreviewWrapper()
        .background(Color.white)
}
