import SwiftUI

struct MapPlaceholder: View {

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.95),
                        Color.black.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea()
            .overlay(
                Text("Map View")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.2))
            )
    }
}


#Preview {
    MapPlaceholder()
}
