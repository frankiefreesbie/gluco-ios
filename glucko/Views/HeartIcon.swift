import SwiftUI

struct HeartIcon: View {
    let isFavorite: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(
                    isFavorite ? 
                    Color.red : 
                    Color.black.opacity(0.5)
                )
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                )
                .overlay(
                    Image(systemName: "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .opacity(isFavorite ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        HeartIcon(isFavorite: false) {
            print("Toggle favorite")
        }
        HeartIcon(isFavorite: true) {
            print("Toggle favorite")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.2))
} 