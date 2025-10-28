import SwiftUI

struct UserProfileSection: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Sarah Wilson")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("sarah.wilson@email.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    UserProfileSection()
        .padding()
}
