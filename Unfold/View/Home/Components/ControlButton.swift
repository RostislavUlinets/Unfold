import SwiftUI

struct ControlButton: View {

    let icon: String
    let action: () -> Void


    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(
                    width: AppDimensions.iconButtonSize,
                    height: AppDimensions.iconButtonSize
                )
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(Color.white.opacity(0.95))
                        .shadow(
                            color: .black.opacity(0.1),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
        }
    }
}


#Preview {
    VStack(spacing: AppSpacing.md) {
        ControlButton(icon: AppIcons.menu) {}
        ControlButton(icon: AppIcons.search) {}
        ControlButton(icon: AppIcons.location) {}
        ControlButton(icon: AppIcons.zoomIn) {}
        ControlButton(icon: AppIcons.zoomOut) {}
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
