import SwiftUI
#if os(iOS)
import UIKit
#endif

struct RecipeDetailsView: View {
    let recipe: Recipe
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date = Date()
    let onAddToPlan: (Recipe) -> Void
    
    // Check if recipe is already in the current day's meals
    private var isRecipeInCurrentDayMeals: Bool {
        let plan = appState.mealPlan(for: selectedDate)
        return plan.breakfast?.id == recipe.id || 
               plan.lunch?.id == recipe.id || 
               plan.dinner?.id == recipe.id
    }
    
    @State private var detailedRecipe: Recipe?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Hero Image Section
                        HeroImageSection(recipe: detailedRecipe ?? recipe)
                        
                        // Content Sections
                        VStack(spacing: 24) {
                            // Recipe Title and Meta
                            RecipeTitleSection(recipe: detailedRecipe ?? recipe)
                            
                            // Macronutrients Section
                            MacronutrientsSection(recipe: detailedRecipe ?? recipe)
                            
                            // Ingredients Section
                            IngredientsSection(recipe: detailedRecipe ?? recipe)
                            
                            // Preparation Section
                            PreparationSection(recipe: detailedRecipe ?? recipe)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Extra space for sticky button
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
                
                // Sticky Add to Plan Button
                VStack {
                    if !isRecipeInCurrentDayMeals {
                        Button(action: {
                            onAddToPlan(recipe)
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                Text("Add to plan")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 48)
                            .background(Color(red: 1, green: 0.48, blue: 0.18))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    } else {
                        // Show "Log your meal" button when recipe is already in plan
                        Button(action: {
                            // TODO: Implement meal logging functionality
                            // This could open a meal logging sheet or navigate to logging flow
                            print("Log meal for recipe: \(recipe.name)")
                        }) {
                            HStack {
                                Spacer()
                                Text("Log your meal")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 48)
                            .background(Color(red: 0.2, green: 0.6, blue: 0.4)) // Green color for logging
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
            }
            
            // Navigation Buttons
            VStack {
                HStack {
                    // Back Button
                    Button(action: { dismiss() }) {
                        Image("chevron-down")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    // Options Button with Native Menu
                    Menu {
                        Button {
                            // TODO: Implement share functionality
                            print("Share recipe: \(recipe.name)")
                        } label: {
                            Label("Share recipe", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            appState.toggleFavorite(for: recipe)
                        } label: {
                            if appState.isFavorite(recipe) {
                                Label("Remove from favourites", systemImage: "heart.fill")
                            } else {
                                Label("Add to favourite", systemImage: "heart")
                            }
                        }
                        
                        // Only show "Remove from Diary" if recipe is in current day's meals
                        if isRecipeInCurrentDayMeals {
                            Button(role: .destructive) {
                                // Remove recipe from current day's meals
                                let plan = appState.mealPlan(for: selectedDate)
                                if plan.breakfast?.id == recipe.id {
                                    appState.removeMeal(for: selectedDate, mealType: .breakfast)
                                } else if plan.lunch?.id == recipe.id {
                                    appState.removeMeal(for: selectedDate, mealType: .lunch)
                                } else if plan.dinner?.id == recipe.id {
                                    appState.removeMeal(for: selectedDate, mealType: .dinner)
                                }
                            } label: {
                                Label("Remove from Diary", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadRecipeDetails()
            }
        }
    }
    
    private func loadRecipeDetails() async {
        // Only fetch details if we don't have ingredients/instructions
        if recipe.ingredients.isEmpty || recipe.instructions.isEmpty {
            if let detailed = await appState.fetchRecipeDetails(for: recipe.id) {
                await MainActor.run {
                    self.detailedRecipe = detailed
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } else {
            await MainActor.run {
                self.detailedRecipe = recipe
                self.isLoading = false
            }
        }
    }
}

// MARK: - Hero Image Section
struct HeroImageSection: View {
    let recipe: Recipe
    
    var body: some View {
        ZStack {
            // Recipe Image
            if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                // Display image from Supabase URL
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        // Loading state
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 400)
                            .overlay(
                                VStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Loading image...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                            )
                    case .success(let image):
                        // Successfully loaded image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 400)
                            .clipped()
                    case .failure(let error):
                        // Failed to load, show placeholder with error info
                        VStack {
                            placeholderView
                            Text("Failed to load image")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                            Text("URL: \(imageURL)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .onAppear {
                            print("❌ Image loading failed for URL: \(imageURL)")
                            print("❌ Error: \(error)")
                        }
                    @unknown default:
                        placeholderView
                    }
                }
                .onAppear {
                    print("🔄 Attempting to load image from: \(imageURL)")
                }
            } else {
                // No image available, show placeholder
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 400)
            .overlay(
                VStack {
                    Image("fork.knife")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.secondary)
                    Text("Recipe Image")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            )
    }
}

// MARK: - Recipe Title Section
struct RecipeTitleSection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.custom("Nunito-Bold", size: 28))
                .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
            
            HStack(spacing: 8) {
                Image("clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color(.systemGray))
                
                Text("\(recipe.prepTime) min - \(recipe.calories)Kcal")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(Color(.systemGray))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Macronutrients Section
struct MacronutrientsSection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MACRONUTRIENTS")
                .font(Font.custom("SF Pro Display", size: 14))
                .kerning(1)
                .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
            
            HStack(spacing: 24) {
                MacronutrientCircle(
                    value: "\(recipe.protein)g",
                    percentage: "10%",
                    label: "Protein",
                    color: Color(red: 1, green: 0.8, blue: 0.2),
                    progress: 0.1
                )
                
                MacronutrientCircle(
                    value: "\(recipe.carbs)g",
                    percentage: "18%",
                    label: "Carbs",
                    color: Color(red: 1, green: 0.48, blue: 0.18),
                    progress: 0.18
                )
                
                MacronutrientCircle(
                    value: "\(recipe.fat)g",
                    percentage: "72%",
                    label: "Fat",
                    color: Color(red: 0.9, green: 0.3, blue: 0.2),
                    progress: 0.72
                )
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct MacronutrientCircle: View {
    let value: String
    let percentage: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 6)
                    .frame(width: 92, height: 92)
                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 92, height: 92)
                    .rotationEffect(.degrees(-90))
                // Value text
                VStack(spacing: 2) {
                    Text(value)
                        .font(.custom("Nunito-Bold", size: 24))
                        .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
                    Text(percentage)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(.systemGray))
                }
            }
            Text(label)
                .font(.custom("Nunito-Bold", size: 14))
                .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
        }
    }
}

// MARK: - Ingredients Section
struct IngredientsSection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("INGREDIENTS")
                    .font(Font.custom("SF Pro Display", size: 14))
                    .kerning(1)
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                
                Spacer()
                
                // Share button
                Button(action: shareIngredients) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 1, green: 0.48, blue: 0.18))
                }
            }
            
            // Ingredients List
            VStack(spacing: 12) {
                ForEach(recipe.ingredients, id: \.id) { ingredient in
                    IngredientRow(name: ingredient.name, quantity: ingredient.displayAmount)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private func shareIngredients() {
        // Create bullet-point list of ingredients
        let ingredientsList = recipe.ingredients.map { ingredient in
            "• \(ingredient.name): \(ingredient.displayAmount)"
        }.joined(separator: "\n")
        
        // Create the full message
        let message = """
        Shopping list for \(recipe.name):
        
        \(ingredientsList)
        """
        
        // Share the ingredients list
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        // Set excluded activity types to show only specific apps
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
            .openInIBooks,
            .postToFacebook,
            .postToFlickr,
            .postToTencentWeibo,
            .postToTwitter,
            .postToVimeo,
            .postToWeibo,
            .print,
            .saveToCameraRoll,
            .airDrop
        ]
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct IngredientRow: View {
    let name: String
    let quantity: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
            
            Spacer()
            
            // Dashed line
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
                .padding(.horizontal, 8)
            
            Text(quantity)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
        }
    }
}

// MARK: - Preparation Section
struct PreparationSection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PREPARATION")
                .font(Font.custom("SF Pro Display", size: 14))
                .kerning(1)
                .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
            
            VStack(spacing: 16) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    PreparationStep(
                        stepNumber: index + 1,
                        instruction: instruction,
                        isLast: index == recipe.instructions.count - 1
                    )
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct PreparationStep: View {
    let stepNumber: Int
    let instruction: String
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step circle and line
            VStack(spacing: 0) {
                Circle()
                    .stroke(Color(red: 1, green: 0.48, blue: 0.18), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("\(stepNumber)")
                            .font(.custom("Inter-Bold", size: 12))
                            .foregroundColor(Color(red: 1, green: 0.48, blue: 0.18))
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 2)
                        .frame(minHeight: 20)
                        .padding(.top, 4)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(stepNumber)")
                    .font(.custom("Inter-Regular", size: 14))
                    .kerning(1)
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                
                Text(instruction)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}



#Preview {
    RecipeDetailsView(
        recipe: Recipe(
            name: "Sample Recipe",
            prepTime: 15,
            tags: ["Sample"],
            description: "A sample recipe for preview",
            ingredients: ["Ingredient 1", "Ingredient 2"],
            instructions: ["Step 1", "Step 2"],
            protein: 20,
            carbs: 30,
            fat: 10,
            calories: 300
        ),
        appState: AppState(),
        onAddToPlan: { _ in }
    )
}

 