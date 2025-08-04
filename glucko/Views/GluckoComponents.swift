import SwiftUI

// MARK: - Recipe Image View
struct RecipeImageView: View {
    let recipe: Recipe
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(recipe: Recipe, height: CGFloat = 200, cornerRadius: CGFloat = 12) {
        self.recipe = recipe
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                // Display image from Supabase URL
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        // Loading state
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    case .success(let image):
                        // Successfully loaded image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        // Failed to load, show placeholder
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else if let imageName = recipe.imageName, !imageName.isEmpty {
                // Display local asset image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // No image available, show placeholder
                placeholderView
            }
        }
        .frame(height: height)
        .clipped()
        .cornerRadius(cornerRadius)
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack {
                    Image("fork.knife")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.secondary)
                    Text("Recipe Image")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            )
    }
}

// MARK: - Font Extensions
extension Font {
    static func nunitoLargeTitle() -> Font {
        return Font.custom("Nunito", size: 34).weight(.bold)
    }
    
    static func nunitoHeader1() -> Font {
        return Font.custom("Nunito", size: 28).weight(.bold)
    }
    
    static func nunitoHeader2() -> Font {
        return Font.custom("Nunito", size: 24).weight(.bold)
    }
    
    static func nunitoHeader3() -> Font {
        return Font.custom("Nunito", size: 18).weight(.bold)
    }
}

// MARK: - Text Style Extensions
extension Text {
    func nunitoLargeTitle() -> some View {
        self.font(.nunitoLargeTitle())
            .lineSpacing(120 - 34) // Line height 120 - font size 34 = 86
    }
    
    func nunitoHeader1() -> some View {
        self.font(.nunitoHeader1())
            .lineSpacing(120 - 28) // Line height 120 - font size 28 = 92
    }
    
    func nunitoHeader2() -> some View {
        self.font(.nunitoHeader2())
            .lineSpacing(120 - 24) // Line height 120 - font size 24 = 96
    }
    
    func nunitoHeader3() -> some View {
        self.font(.nunitoHeader3())
            .lineSpacing(130 - 18) // Line height 130 - font size 18 = 112
    }
}

// MARK: - GluckoCard
struct GluckoCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding()
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - GluckoTag
struct GluckoTag: View {
    let text: String
    var color: Color = Color.gray.opacity(0.2)
    var textColor: Color = Color.black
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(textColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
            .accessibilityLabel(text)
    }
}

// MARK: - GluckoButton
struct GluckoButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.accentColor))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - GluckoSecondaryButton
struct GluckoSecondaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(red: 1, green: 0.478, blue: 0.18))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 1, green: 0.478, blue: 0.18), lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.clear))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
}