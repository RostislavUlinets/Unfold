import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Unfold")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                .scaleEffect(scale)
                .opacity(opacity)

            Spacer()

            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
                .padding(.bottom, 50)
                .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.smooth(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
