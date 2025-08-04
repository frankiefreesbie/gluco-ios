import SwiftUI
#if os(iOS)
import UIKit
#endif

struct PlanView: View {
    @Binding var selectedDate: Date
    var plan: DailyMealPlan
    var onAppear: () -> Void
    var onDateChange: (Date) -> Void
    @EnvironmentObject var appState: AppState
    @State private var showingSuggestionSheet: Bool = false
    @State private var suggestionMealType: String? = nil
    @State private var selectedRecipe: Recipe? = nil
    @State private var showingRecipeDetailSheet: Bool = false
    @State private var showingShareSheet: Bool = false

    // Function to generate weekly grocery list
    private func generateWeeklyGroceryList() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var allIngredients: [String: (name: String, amount: String)] = [:]
        
        // Collect ingredients from the entire week (7 days)
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
            let plan = appState.mealPlan(for: date)
            let meals = [plan.breakfast, plan.lunch, plan.dinner].compactMap { $0 }
            
            for meal in meals {
                for ingredient in meal.groceryListIngredients {
                    let key = ingredient.name.lowercased()
                    if allIngredients[key] == nil {
                        // First occurrence
                        allIngredients[key] = (name: ingredient.name, amount: ingredient.displayAmount)
                    }
                }
            }
        }
        
        // Format the grocery list
        let groceryList = allIngredients.values
            .sorted { $0.name < $1.name }
            .map { "• \($0.name): \($0.amount)" }
            .joined(separator: "\n")
        
        // Format the date range
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let startDate = dateFormatter.string(from: today)
        let endDate = dateFormatter.string(from: calendar.date(byAdding: .day, value: 6, to: today) ?? today)
        
        return """
        Weekly grocery list (\(startDate) - \(endDate)):
        
        \(groceryList)
        """
    }
    
    private func shareWeeklyGroceryList() {
        let message = generateWeeklyGroceryList()
        
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
            .saveToCameraRoll
        ]
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            PlanHeaderView()
            CalendarRow(selectedDate: $selectedDate)
                .padding(.top, 8)
                .padding(.bottom, 8)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Today's meals")
                            .font(.title2).bold()
                        Spacer()
                        Menu {
                            Button {
                                print("Send grocery list tapped")
                                shareWeeklyGroceryList()
                            } label: {
                                Label("Send grocery list", systemImage: "send")
                            }
                            
                            Button {
                                print("Debug: Menu is working")
                            } label: {
                                Label("Debug option", systemImage: "info.circle")
                            }
                        } label: {
                            Image("more")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 8)
                    MealSection(mealName: "Breakfast", recipe: plan.breakfast, onSuggest: { suggestionMealType = "Breakfast"; showingSuggestionSheet = true }, onDetail: { recipe in selectedRecipe = recipe; showingRecipeDetailSheet = true })
                    MealSection(mealName: "Lunch", recipe: plan.lunch, onSuggest: { suggestionMealType = "Lunch"; showingSuggestionSheet = true }, onDetail: { recipe in selectedRecipe = recipe; showingRecipeDetailSheet = true })
                    MealSection(mealName: "Dinner", recipe: plan.dinner, onSuggest: { suggestionMealType = "Dinner"; showingSuggestionSheet = true }, onDetail: { recipe in selectedRecipe = recipe; showingRecipeDetailSheet = true })
                    NutritionalValuesSection()
                    GroceryListSection(ingredients: ["Quinoa", "Black beans", "Sweet potatoes", "Salmon", "Eggs", "Feta", "Spinach", "Lentils", "Beans"])
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
        .onAppear(perform: onAppear)
        .onChange(of: selectedDate) { oldValue, newValue in
            onDateChange(newValue)
        }
        .sheet(isPresented: $showingSuggestionSheet) {
            MealSuggestionSheet(
                recipes: appState.recipes,
                onAdd: { recipe in print("Add meal: \(recipe.name) for \(suggestionMealType ?? "")") },
                onDetail: { recipe in selectedRecipe = recipe; showingRecipeDetailSheet = true }
            )
        }
        .sheet(isPresented: $showingRecipeDetailSheet) {
            if let recipe = selectedRecipe {
                RecipeDetailSheet(recipe: recipe, onAdd: { print("Add meal: \(recipe.name)") })
            }
        }
    }
}

struct PlanHeaderView: View {
    var body: some View {
        HStack {
            Image("clock")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.orange)
            Spacer()
            Image("gluco")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
            Spacer()
            HStack(spacing: 16) {
                Button(action: {/* Profile */}) {
                    Image("user")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                }
                Button(action: {/* Settings */}) {
                    Image("edit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

struct MealSection: View {
    let mealName: String
    let recipe: Recipe?
    var onSuggest: () -> Void = {}
    var onDetail: (Recipe) -> Void = { _ in }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mealName.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 8)
            if let recipe = recipe {
                GluckoCard {
                    VStack(alignment: .leading, spacing: 8) {
                        if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                            // Display image from Supabase URL
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    // Loading state
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 140)
                                        .cornerRadius(12)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        )
                                case .success(let image):
                                    // Successfully loaded image
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 140)
                                        .clipped()
                                        .cornerRadius(12)
                                case .failure(_):
                                    // Failed to load, show placeholder
                                    placeholderView
                                @unknown default:
                                    placeholderView
                                }
                            }
                        } else if let imageName = recipe.imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 140)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            // No image available, show placeholder
                            placeholderView
                        }
                        HStack {
                            Text(recipe.name)
                                .font(.headline)
                            Spacer()
                            Button(action: {/* Show meal menu */}) {
                                Image("more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.primary)
                            }
                        }
                        HStack(spacing: 12) {
                            Label("\(recipe.prepTime) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(recipe.calories) Kcal")
                                .font(.caption)
                                .foregroundColor(.gray)
                            ForEach(recipe.tags, id: \.self) { tag in
                                GluckoTag(text: tag)
                            }
                        }
                    }
                    .onTapGesture { onDetail(recipe) }
                }
            } else {
                MealEmptyStateCard(mealName: mealName, onSuggest: onSuggest)
            }
        }
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 140)
            .cornerRadius(12)
            .overlay(
                VStack {
                    Image("fork.knife")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.secondary)
                    Text("Recipe Image")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            )
    }
}

struct NutritionalValuesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NUTRITIONAL VALUES")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 8)
            GluckoCard {
                HStack(spacing: 0) {
                    NutrientValueView(value: "250g", label: "Protein")
                    Divider().frame(height: 40)
                    NutrientValueView(value: "65g", label: "Carbs")
                    Divider().frame(height: 40)
                    NutrientValueView(value: "3.567", label: "Kcal")
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct NutrientValueView: View {
    let value: String
    let label: String
    var body: some View {
        VStack {
            Text(value)
                .font(.title3).bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GroceryListSection: View {
    let ingredients: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("GROCERY LIST")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {/* Share list */}) {
                    Label("Share list", systemImage: "square.and.arrow.up")
                        .font(.caption)
                }
            }
            GluckoCard {
                WrapHStack(spacing: 8) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        GluckoTag(text: ingredient)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct WrapHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: spacing) {
                content()
            }
        }
    }
}

struct MealEmptyStateCard: View {
    let mealName: String
    var onSuggest: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mealName.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 8)
            GluckoCard {
                VStack(spacing: 16) {
                    Text("No idea what to eat?")
                        .font(.title3).bold()
                        .foregroundColor(Color(.systemTeal))
                        .multilineTextAlignment(.center)
                    Text("Glucko can suggest the best meal for you")
                        .font(.body)
                        .foregroundColor(Color(.systemTeal))
                        .multilineTextAlignment(.center)
                    GluckoButton(title: "Suggest me a meal", action: onSuggest)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
    }
}

struct MealSuggestionSheet: View {
    let recipes: [Recipe]
    var onAdd: (Recipe) -> Void
    var onDetail: (Recipe) -> Void
    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.headline)
                        Text("\(recipe.prepTime) min • \(recipe.calories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack(spacing: 6) {
                            ForEach(recipe.tags, id: \.self) { tag in
                                GluckoTag(text: tag)
                            }
                        }
                    }
                    Spacer()
                    Button(action: { onAdd(recipe) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { onDetail(recipe) }
            }
            .navigationTitle("Suggest a Meal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecipeDetailSheet: View {
    let recipe: Recipe
    var onAdd: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text(recipe.name)
                .font(.title2).bold()
                .padding(.top)
            Text("\(recipe.prepTime) min • \(recipe.calories) kcal")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack(spacing: 6) {
                ForEach(recipe.tags, id: \.self) { tag in
                    GluckoTag(text: tag)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredients:").bold()
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("- \(ingredient)")
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions:").bold()
                ForEach(recipe.instructions, id: \.self) { step in
                    Text("- \(step)")
                }
            }
            Spacer()
            GluckoButton(title: "Add Meal", action: onAdd)
                .padding(.bottom)
        }
        .padding()
    }
}

struct CalendarRow: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    private var weekDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7) { idx in
                let date = weekDates[idx]
                let isSelected = selectedDate == date
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .frame(width: 56, height: 64)
                    }
                    VStack(spacing: 4) {
                        Text(weekDays[idx])
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.teal)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.teal)
                    }
                    .frame(width: 56, height: 64)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedDate = date }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

struct MealCard: View {
    let title: String
    let recipe: Recipe?
    let onShowDetail: (Recipe) -> Void
    let onSuggest: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            if let recipe = recipe {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.teal)
                        HStack(spacing: 6) {
                            ForEach(recipe.tags, id: \.self) { tag in
                                GluckoTag(text: tag)
                            }
                        }
                        Text("\(recipe.prepTime)min - \(recipe.calories)kcal")
                            .font(.system(size: 14))
                            .foregroundColor(.teal)
                    }
                    Spacer()
                    Button(action: { onShowDetail(recipe) }) {
                        Image("info")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.teal)
                    }
                }
            } else {
                GluckoButton(title: "Suggest a recipe", action: onSuggest)
            }
        }
    }
}
