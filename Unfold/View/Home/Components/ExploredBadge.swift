import SwiftUI

struct ExploredBadge: View {

    let percentage: Double


    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "eye.fill")
                .font(.subheadline)
            Text("\(Int(percentage))% Explored")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.8), Color.teal.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}


#Preview {
    VStack(spacing: 20) {
        ExploredBadge(percentage: 12)
        ExploredBadge(percentage: 45)
        ExploredBadge(percentage: 87)
    }
    .padding()
    .background(Color.gray)
}
