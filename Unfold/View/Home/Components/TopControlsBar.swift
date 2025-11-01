import SwiftUI

struct TopControlsBar: View {
    let exploredPercentage: Double
    let onLocationTapped: () -> Void
    let onLogoutTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ControlButton(icon: "rectangle.portrait.and.arrow.right") {
                onLogoutTapped()
            }

            Spacer()

            ExploredBadge(percentage: exploredPercentage)

            Spacer()

            ControlButton(icon: "location.fill") {
                onLocationTapped()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
    }
}

#Preview {
    TopControlsBar(
        exploredPercentage: 12,
        onLocationTapped: {},
        onLogoutTapped: {}
    )
    .background(Color.black)
}
