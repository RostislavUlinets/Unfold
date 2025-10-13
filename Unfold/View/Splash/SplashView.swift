import SwiftUI

struct SplashView: View{
    
    var body: some View {
        VStack {
            Spacer()
            Text("Unfold")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 8)
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
