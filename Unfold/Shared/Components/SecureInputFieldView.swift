import SwiftUI

struct SecureInputFieldView: View {

    let label: String
    @Binding var text: String
    let placeholder: String
    @State private var isSecureVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.headline)
                .foregroundColor(AppColors.authBackground)

            HStack {
                inputField

                Button(action: toggleVisibility) {
                    Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppColors.authBackground.opacity(0.6))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
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
        if isSecureVisible {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        } else {
            SecureField(placeholder, text: $text)
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
