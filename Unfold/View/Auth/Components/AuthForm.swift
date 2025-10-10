import SwiftUI

struct AuthFormView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    let parentSize: CGSize

    var body: some View {
        VStack {
            
            Text("Email")
                .font(.headline)
                .foregroundColor(.authBackground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            TextField("Email", text: $email)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.authBackground, lineWidth: 1)
                )
                .padding(.horizontal)
            
            Text("Password")
                .font(.headline)
                .foregroundColor(.authBackground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.authBackground, lineWidth: 1)
                )
                .padding(.horizontal)
            
            Button(action: {
                            // Handle login action here
                        }) {
                            Text("Login")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.authBackground)
                                .cornerRadius(24)
                        }
                        .frame(width: parentSize.width * 0.6, height: 55)
                        .padding(.horizontal)
                        .padding(.top, 10)
            
            Text("Or Sign Up Here")
                .font(.footnote)
                .foregroundColor(.authBackground)
                .padding(.horizontal)
            
            Spacer()
            
            Text("Terms & Conditions")
                .font(.caption)
                .foregroundColor(.authBackground)
                .padding(.horizontal)
            
            
        }
    }
}
