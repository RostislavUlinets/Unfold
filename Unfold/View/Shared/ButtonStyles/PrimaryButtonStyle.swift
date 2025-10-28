import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {

    var isDisabled = false


    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.smooth(duration: AppAnimation.quick), value: configuration.isPressed)
    }


    private func backgroundColor(isPressed: Bool) -> Color {
        if isDisabled {
            return AppColors.authBackground.opacity(0.5)
        }
        return isPressed
            ? AppColors.authBackground.opacity(0.8)
            : AppColors.authBackground
    }
}


#Preview {
    VStack(spacing: AppSpacing.md) {
        Button("Primary Button") {}
            .buttonStyle(PrimaryButtonStyle())

        Button("Disabled Button") {}
            .buttonStyle(PrimaryButtonStyle(isDisabled: true))
            .disabled(true)

        Button {
            // Action
        } label: {
            Label("Send Email", systemImage: AppIcons.email)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
}
