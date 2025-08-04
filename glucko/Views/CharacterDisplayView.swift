import SwiftUI

struct CharacterDisplayView: View {
    // Removed: @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            // TODO: Refactor or remove characterState and userPoints usages below as they are no longer present in AppState
            Text("\u{1F464}") // Placeholder for emoji
                .font(.system(size: 80))
                .scaleEffect(1.0) // Placeholder for scale effect
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: 0) // Placeholder for animation
            
            Text("Gluko")
                .font(.custom("Nunito-Bold", size: 18))
            
            Text("Hello, I'm Gluko! \u{1F36C}") // Placeholder for message
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.custom("Inter-Regular", size: 12))
                    Spacer()
                    Text("0/150 XP") // Placeholder for XP
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                
                ProgressView(value: 0.0, total: 150) // Placeholder for progress view
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("\u{1F525} Streak")
                        .font(.custom("Inter-Regular", size: 12))
                    Spacer()
                    Text("0 days") // Placeholder for streak
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
