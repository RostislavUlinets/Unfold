import SwiftUI

struct AuthPageView: View {
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.authBackground
                    .ignoresSafeArea()
                
                VStack() {
                    VStack() {
                        Spacer()
                        Text("Hello & Welcome!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    VStack(spacing: 40) {
                        AuthHeaderView()
                        
                        AuthFormView(parentSize: geometry.size)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.6,
                           alignment: .top)
                    .background(
                        Color.white
                            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                            .edgesIgnoringSafeArea(.bottom)
                    )
                    
                    
                }
                
                
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 25.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}

#Preview {
    AuthPageView()
}
