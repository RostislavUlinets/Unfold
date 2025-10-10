import SwiftUI

struct AuthHeaderView: View {
    @State private var selectedTab: String = "Login"

    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.authBackground)
                    .onTapGesture {
                        selectedTab = "Login"
                    }
                Rectangle()
                    .fill(selectedTab == "Login" ? Color.authBackground : Color.clear)
                    .frame(height: 2)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.authBackground)
                    .onTapGesture {
                        selectedTab = "Sign Up"
                    }
                Rectangle()
                    .fill(selectedTab == "Sign Up" ? Color.authBackground : Color.clear)
                    .frame(height: 2)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}
