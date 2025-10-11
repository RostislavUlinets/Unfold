import SwiftUI

struct AuthHeaderView: View {
    @Binding var selectedMode: AuthMode

    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.authBackground)
                    .onTapGesture {
                        selectedMode = AuthMode.login
                    }
                Rectangle()
                    .fill(selectedMode == AuthMode.login ? Color.authBackground : Color.clear)
                    .frame(height: 2)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.authBackground)
                    .onTapGesture {
                        selectedMode = AuthMode.signup
                    }
                Rectangle()
                    .fill(selectedMode == AuthMode.signup ? Color.authBackground : Color.clear)
                    .frame(height: 2)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}
