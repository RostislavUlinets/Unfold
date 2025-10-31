import SwiftUI
import MapKit

struct TopControlsBar: View {

    @Binding var showSideMenu: Bool
    @Binding var mapRegion: MKCoordinateRegion
    let exploredPercentage: Double
    let onLocationTapped: () -> Void


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
        showSideMenu: .constant(false),
        mapRegion: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )),
        exploredPercentage: 12,
        onLocationTapped: {}
    )
    .background(Color.black)
}
