import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColors.authBackground)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(AppColors.authBackground, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.smooth(duration: AppAnimation.quick), value: configuration.isPressed)
    }
}


#Preview {
    VStack(spacing: AppSpacing.md) {
        Button("Secondary Button") {}
            .buttonStyle(SecondaryButtonStyle())

        Button("Cancel") {}
            .buttonStyle(SecondaryButtonStyle())

        Button("Learn More") {}
            .buttonStyle(SecondaryButtonStyle())
    }
    .padding()
}
