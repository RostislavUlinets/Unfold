import SwiftUI

struct InputFieldView: View {

    let label: String
    @Binding var text: String
    let placeholder: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure = false


    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.authBackground)
                    .frame(width: 24)
            }

            inputField
        }
        .padding()
        .background(AppColors.authInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
    }


    @ViewBuilder
    private var inputField: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .foregroundColor(AppColors.authBackground)
                .font(.system(size: 16))
        } else {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(AppColors.authBackground)
                .font(.system(size: 16))
        }
    }
}


#Preview {
    VStack(spacing: AppSpacing.md) {
        InputFieldView(
            label: Strings.Auth.email,
            text: .constant(""),
            placeholder: "Enter your email",
            keyboardType: .emailAddress
        )

        InputFieldView(
            label: Strings.Auth.password,
            text: .constant(""),
            placeholder: "Enter your password",
            isSecure: true
        )

        InputFieldView(
            label: Strings.Auth.confirmPassword,
            text: .constant(""),
            placeholder: "Re-enter password",
            isSecure: true
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
