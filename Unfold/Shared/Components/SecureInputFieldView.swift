import SwiftUI

struct SecureInputFieldView: View {

    let label: String
    @Binding var text: String
    let placeholder: String
    var icon: String? = nil
    @State private var isSecureVisible = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.authBackground)
                    .frame(width: 24)
            }

            inputField

            Button(action: toggleVisibility) {
                Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(AppColors.authBackground.opacity(0.7))
                    .frame(width: 24, height: 24)
            }
        }
        .padding()
        .background(AppColors.authInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill))
    }

    @ViewBuilder
    private var inputField: some View {
        if isSecureVisible {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(AppColors.authBackground)
                .font(.system(size: 16))
        } else {
            SecureField(placeholder, text: $text)
                .foregroundColor(AppColors.authBackground)
                .font(.system(size: 16))
        }
    }

    private func toggleVisibility() {
        isSecureVisible.toggle()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        SecureInputFieldView(
            label: "Password",
            text: .constant("password123"),
            placeholder: "Enter your password"
        )

        SecureInputFieldView(
            label: "Confirm Password",
            text: .constant(""),
            placeholder: "Re-enter password"
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
