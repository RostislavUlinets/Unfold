import SwiftUI

struct TopControlsBar: View {

    @Binding var showSideMenu: Bool
    let exploredPercentage: Double


    var body: some View {
        HStack(spacing: 12) {
            ControlButton(icon: "line.3.horizontal") {
                withAnimation(.smooth(duration: 0.3)) {
                    showSideMenu.toggle()
                }
            }

            Spacer()

            ExploredBadge(percentage: exploredPercentage)

            Spacer()

            ControlButton(icon: "magnifyingglass") {}
            ControlButton(icon: "location.fill") {}
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
    }
}


#Preview {
    TopControlsBar(
        showSideMenu: .constant(false),
        exploredPercentage: 12
    )
    .background(Color.black)
}
