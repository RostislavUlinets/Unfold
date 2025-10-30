import SwiftUI

struct InputFieldView: View {

    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isSecure = false


    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.headline)
                .foregroundColor(AppColors.authBackground)

            inputField
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.pill)
                        .stroke(AppColors.authBackground, lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }


    @ViewBuilder
    private var inputField: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
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
