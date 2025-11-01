import SwiftUI

struct ControlButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ControlButton(icon: "line.3.horizontal") {}
        ControlButton(icon: "magnifyingglass") {}
        ControlButton(icon: "location.fill") {}
        ControlButton(icon: "plus") {}
        ControlButton(icon: "minus") {}
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
