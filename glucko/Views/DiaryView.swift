import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DiaryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var showingSuggestionSheet: Bool = false
    @State private var suggestionMealType: String? = nil
    @State private var selectedRecipe: Recipe? = nil
    @State private var showProfile = false
    @State private var showAddMenu: Bool = false
    @State private var addMenuMealType: String? = nil
    @State private var showRecipesSheet: Bool = false
    @State private var showSwapRecipesSheet: Bool = false
    @State private var swapMealType: MealType? = nil
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    SharedHeaderView(
                        onUserTap: { showProfile = true },
                        onWeekPlanTap: {
                            appState.generateWeeklyMealPlan()
                        },
                        onShareGroceryList: {
                            shareWeeklyGroceryList()
                        }
                    )
                    // Profile navigation will be handled with custom presentation
                    WeekTrackerView(selectedDate: $selectedDate)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    ScrollView {
                        VStack(spacing: 24) {
                            // Meal Diary Section
                            MealDiarySection(
                                selectedDate: selectedDate,
                                onSuggest: { mealType in
                                    suggestionMealType = mealType
                                    showingSuggestionSheet = true
                                },
                                onDetail: { recipe in
                                    selectedRecipe = recipe
                                },
                                onAddMenu: { mealType in
                                    addMenuMealType = mealType
                                    showRecipesSheet = true
                                },
                                swapMealType: $swapMealType,
                                showSwapRecipesSheet: $showSwapRecipesSheet
                            )
                            // Grocery List
                            GroceryListView(selectedDate: selectedDate)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 100) // Space for tab bar
                    }
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea())
            }
            .onAppear {
                appState.ensureMealPlan(for: selectedDate)
            }
            .onChange(of: selectedDate) { _, newValue in
                appState.ensureMealPlan(for: newValue)
            }
            
            // Custom Profile view overlay with push animation
            if showProfile {
                ProfileView(showProfile: $showProfile)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(1000)
                    .animation(.easeInOut(duration: 0.3), value: showProfile)
            }
        }
        .sheet(isPresented: $showingSuggestionSheet) {
            MealSuggestionSheet(
                recipes: appState.recipes,
                onAdd: { recipe in
                    addMeal(recipe, for: suggestionMealType ?? "")
                },
                onDetail: { recipe in
                    selectedRecipe = recipe
                }
            )
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailsView(
                recipe: recipe,
                appState: appState,
                onAddToPlan: { _ in }
            )
        }

        .sheet(isPresented: $showRecipesSheet) {
            NavigationStack {
                RecipesView(
                    selectedMealType: addMenuMealType,
                    selectedDate: selectedDate,
                    onAddToPlan: { recipe in
                        if let mealType = addMenuMealType {
                            addMeal(recipe, for: mealType)
                        }
                        showRecipesSheet = false
                    }
                )
            }
        }
        .sheet(isPresented: $showSwapRecipesSheet) {
            NavigationStack {
                RecipesView(
                    selectedMealType: swapMealType?.rawValue,
                    selectedDate: selectedDate,
                    onAddToPlan: { recipe in
                        if let mealType = swapMealType {
                            appState.addMeal(recipe, for: selectedDate, mealType: mealType)
                        }
                        showSwapRecipesSheet = false
                    }
                )
            }
        }
    }
    
    private func addMeal(_ recipe: Recipe, for mealType: String) {
        let plan = appState.mealPlan(for: selectedDate)
        var newPlan = plan
        switch mealType {
        case "Breakfast":
            newPlan.breakfast = recipe
        case "Lunch":
            newPlan.lunch = recipe
        case "Dinner":
            newPlan.dinner = recipe
        default:
            break
        }
        appState.setMealPlan(newPlan, for: selectedDate)
    }
    
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
}

// MARK: - Header Components

struct WeekTrackerView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var appState: AppState
    private let calendar = Calendar.current
    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    
    private var weekDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        // Calculate days to subtract to get to Monday (weekday 2)
        // If today is Monday (2), subtract 0; if Tuesday (3), subtract 1; etc.
        let daysToSubtract = (weekday + 5) % 7 // 0 if Monday, 1 if Tuesday, ..., 6 if Sunday
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<7) { idx in
                let date = weekDates[idx]
                let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)
                let isCompleted = hasCompletedMeals(for: date)
                
                Button(action: { selectedDate = date }) {
                                            ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 48, height: 81)
                                .background(isSelected ? .white : Color.clear)
                                .cornerRadius(8.33401)
                                .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
                        
                        VStack(spacing: 8) {
                            Text(weekDays[idx])
                                .font(Font.custom("Inter", size: 14))
                                .kerning(0.2778)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
                                .frame(width: 47.92057, alignment: .top)
                            
                            Text("\(calendar.component(.day, from: date))")
                                .nunitoHeader3()
                                .kerning(0.17363)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
                                .frame(width: 47.92057, alignment: .top)
                            
                            // Show check icon if meals exist, circle icon if no meals
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func hasCompletedMeals(for date: Date) -> Bool {
        // Check actual meal plan data - only show checkmark if there are real meals
        let plan = appState.mealPlan(for: date)
        return plan.breakfast != nil || plan.lunch != nil || plan.dinner != nil
    }
}

// MARK: - Meal Diary Section

struct MealDiarySection: View {
    let selectedDate: Date
    let onSuggest: (String) -> Void
    let onDetail: (Recipe) -> Void
    let onAddMenu: (String) -> Void
    @Binding var swapMealType: MealType?
    @Binding var showSwapRecipesSheet: Bool
    @EnvironmentObject var appState: AppState
    
    private var dayTitle: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        
        if calendar.isDate(selectedDay, inSameDayAs: today) {
            return "Today's meals"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: selectedDate)
            return "\(dayName)'s meals"
        }
    }
    
    // Function to get the actual recipe for a meal type from the meal plan
    private func getDatabaseRecipe(for date: Date, mealType: MealType) -> Recipe? {
        let plan = appState.mealPlan(for: date)
        switch mealType {
        case .breakfast:
            return plan.breakfast
        case .lunch:
            return plan.lunch
        case .dinner:
            return plan.dinner
        }
    }
    
    // Check if the day has any meals
    private var hasAnyMeals: Bool {
        let breakfast = getDatabaseRecipe(for: selectedDate, mealType: .breakfast)
        let lunch = getDatabaseRecipe(for: selectedDate, mealType: .lunch)
        let dinner = getDatabaseRecipe(for: selectedDate, mealType: .dinner)
        return breakfast != nil || lunch != nil || dinner != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Dynamic day meals title
            HStack {
                Text(dayTitle)
                    .nunitoHeader2()
                    .kerning(0.15)
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                    .frame(width: 245, alignment: .topLeading)
                Spacer()
            }
            .padding(.bottom, 24)
            
            // Generate meals banner - only show if no meals exist
            if !hasAnyMeals {
                GenerateMealsBanner(selectedDate: selectedDate)
                    .padding(.bottom, 24)
            }
            
            // Timeline container with numbered steps design
            VStack(spacing: 24) {
                    TimelineMealSection(
                        title: "BREAKFAST",
                        recipe: getDatabaseRecipe(for: selectedDate, mealType: .breakfast),
                        onAdd: { onSuggest("Breakfast") },
                        onDetail: onDetail,
                        selectedDate: selectedDate,
                        mealType: .breakfast,
                        onAddMenu: { onAddMenu("Breakfast") },
                        onSwap: {
                            swapMealType = .breakfast
                            showSwapRecipesSheet = true
                        },
                        onDeleteAll: {
                            appState.removeMeal(for: selectedDate, mealType: .breakfast)
                        }
                    )
                    
                    TimelineMealSection(
                        title: "LUNCH",
                        recipe: getDatabaseRecipe(for: selectedDate, mealType: .lunch),
                        onAdd: { onSuggest("Lunch") },
                        onDetail: onDetail,
                        selectedDate: selectedDate,
                        mealType: .lunch,
                        onAddMenu: { onAddMenu("Lunch") },
                        onSwap: {
                            swapMealType = .lunch
                            showSwapRecipesSheet = true
                        },
                        onDeleteAll: {
                            appState.removeMeal(for: selectedDate, mealType: .lunch)
                        }
                    )
                    
                    TimelineMealSection(
                        title: "DINNER",
                        recipe: getDatabaseRecipe(for: selectedDate, mealType: .dinner),
                        onAdd: { onSuggest("Dinner") },
                        onDetail: onDetail,
                        selectedDate: selectedDate,
                        mealType: .dinner,
                        onAddMenu: { onAddMenu("Dinner") },
                        onSwap: {
                            swapMealType = .dinner
                            showSwapRecipesSheet = true
                        },
                        onDeleteAll: {
                            appState.removeMeal(for: selectedDate, mealType: .dinner)
                        }
                    )
                }
            }
        }
    }

struct TimelineMealSection: View {
    let title: String
    let recipe: Recipe?
    let onAdd: () -> Void
    let onDetail: (Recipe) -> Void
    let selectedDate: Date
    let mealType: MealType
    let onAddMenu: () -> Void
    let onSwap: () -> Void
    let onDeleteAll: () -> Void
    @EnvironmentObject var appState: AppState
    
    // Helper functions for timeline step numbering
    private func getStepNumber() -> String {
        switch mealType {
        case .breakfast:
            return "1"
        case .lunch:
            return "2"
        case .dinner:
            return "3"
        }
    }
    
    private func isLastStep() -> Bool {
        return mealType == .dinner
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline step circle and line (using Preparation steps design)
            VStack(spacing: 0) {
                Circle()
                    .stroke(Color(red: 1, green: 0.48, blue: 0.18), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(getStepNumber())
                            .font(.custom("Inter-Bold", size: 12))
                            .foregroundColor(Color(red: 1, green: 0.48, blue: 0.18))
                    )
                
                // Line connecting to next step (except for last step)
                if !isLastStep() {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 2)
                        .frame(minHeight: 20)
                        .padding(.top, 4)
                        .overlay(
                            // Create dotted effect with multiple small rectangles
                            VStack(spacing: 2) {
                                ForEach(0..<10, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 2, height: 2)
                                }
                            }
                        )
                }
            }
            .offset(y: -4)   
            
            // Content area
            VStack(alignment: .leading, spacing: 12) {
                // Section header with title and add button
                HStack(alignment: .center) {
                    Text(title)
                        .font(Font.custom("SF Pro Display", size: 14))
                        .fontWeight(.bold)
                        .kerning(1)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // #333333
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            onSwap()
                        } label: {
                            Label("Swap to another recipe", systemImage: "wand.and.stars")
                        }
                        
                        Button {
                            onAddMenu()
                        } label: {
                            Label("Add a recipe", systemImage: "plus")
                        }
                        
                        // Only show "Delete all recipes" when there's a recipe
                        if recipe != nil {
                            Button(role: .destructive) {
                                onDeleteAll()
                            } label: {
                                Label("Delete all recipes", systemImage: "trash")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                            Text("Edit")
                                .font(.custom("Inter-Regular", size: 14))
                        }
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.5)) // #6B7280
                    }
                }
                
                // Add some spacing between edit button and meal card
                .padding(.bottom, 8)
                
                // Meal card or empty state
                if let recipe = recipe {
                    TimelineMealCard(recipe: recipe, onDetail: onDetail, selectedDate: selectedDate, mealType: mealType)
                } else {
                    TimelineEmptyMealCard(onAdd: onAddMenu)
                }
            }
        }
    }
}

struct TimelineMealCard: View {
    let recipe: Recipe
    let onDetail: (Recipe) -> Void
    let selectedDate: Date
    let mealType: MealType
    @EnvironmentObject var appState: AppState
    @State private var showLogBanner = false
    @State private var logBgColor = Color(red: 1, green: 0.96, blue: 0.82)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Meal image
            ZStack(alignment: .topTrailing) {
                if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                    // Display image from Supabase URL
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            // Loading state
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(12)
                                .overlay(
                                    VStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Text("Loading...")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        case .success(let image):
                            // Successfully loaded image
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        case .failure(let error):
                            // Failed to load, show placeholder
                            placeholderView
                                .onAppear {
                                    print("❌ TimelineMealCard: Image loading failed for URL: \(imageURL)")
                                    print("❌ Error: \(error)")
                                }
                        @unknown default:
                            placeholderView
                        }
                    }
                    .onAppear {
                        print("🔄 TimelineMealCard: Attempting to load image from: \(imageURL)")
                    }
                } else {
                    // No image available, show placeholder
                    placeholderView
                }
            }
            // Meal details
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("\(recipe.prepTime) min - \(recipe.calories)Kcal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                // Nutrient tags with updated colors
                HStack(spacing: 8) {
                    NutrientTag(value: "\(recipe.protein)g", label: "Protein", color: Color(red: 0.996, green: 0.949, blue: 0.78))
                    NutrientTag(value: "\(recipe.carbs)g", label: "Carbs", color: Color(red: 0.890, green: 0.890, blue: 0.890))
                    NutrientTag(value: "\(recipe.calories)", label: "Fat", color: Color(red: 0.878, green: 0.906, blue: 1.0))
                }
            }
            // Log entry (persistent, with animated bg)
            if let log = appState.loggedMeals.last(where: { Calendar.current.isDate($0.loggedAt, inSameDayAs: selectedDate) && $0.mealType == mealType }) {
                if let imageData = log.imageData, let userImage = UIImage(data: imageData) {
                    // Show logged meal with user image
                    HStack(spacing: 8) {
                        Image(uiImage: userImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Text("Logged at \(formattedTime(log.loggedAt)) · Earned \(log.pointsEarned) pts 🎉")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(8)
                    .background(logBgColor)
                    .cornerRadius(8)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: logBgColor)
                    .onAppear {
                        logBgColor = Color(red: 1, green: 0.96, blue: 0.82)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                logBgColor = .white
                            }
                        }
                    }
                } else {
                    // Show simple text feedback for logged meal without image
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Meal logged successfully! Earned \(log.pointsEarned) pts 🎉")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(8)
                    .background(logBgColor)
                    .cornerRadius(8)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: logBgColor)
                    .onAppear {
                        logBgColor = Color(red: 1, green: 0.96, blue: 0.82)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                logBgColor = .white
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onDetail(recipe)
        }
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .cornerRadius(12)
            .overlay(
                VStack {
                    Image("fork.knife")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.secondary)
                    Text("Meal Image")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                }
            )
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    

}

struct TimelineEmptyMealCard: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Image placeholder with centered button
            ZStack {
                // Image placeholder background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.9, green: 0.9, blue: 0.9)) // Darker grey for better visibility
                    .frame(height: 180)
                
                // Centered "Add recipe" button
                Button(action: onAdd) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Text("Add recipe")
                            .font(.custom("Inter-SemiBold", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 32)
                    .background(Color(red: 1, green: 0.478, blue: 0.18)) // Primary color from design system
                    .cornerRadius(8)
                }
            }
            
            // Text placeholders
            VStack(alignment: .leading, spacing: 12) {
                // First line - full width (recipe title placeholder)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.88, green: 0.88, blue: 0.88)) // #E0E0E0
                    .frame(height: 16)
                
                // Second line - shorter width (~60%) (description placeholder)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.88, green: 0.88, blue: 0.88)) // #E0E0E0
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
                    .frame(width: UIScreen.main.bounds.width * 0.6)
                
                // Third line - 3 pill-shaped placeholders (metadata)
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.88, green: 0.88, blue: 0.88)) // #E0E0E0
                        .frame(width: 60, height: 24)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.88, green: 0.88, blue: 0.88)) // #E0E0E0
                        .frame(width: 50, height: 24)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.88, green: 0.88, blue: 0.88)) // #E0E0E0
                        .frame(width: 40, height: 24)
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97)) // App background color #F7F7F7
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.83, green: 0.82, blue: 0.82), lineWidth: 1) // #D3D2D2 border
        )
        .frame(height: 320) // Match the height of filled recipe cards
    }
}

struct MealSectionView: View {
    let title: String
    let recipe: Recipe?
    let onAdd: () -> Void
    let onDetail: (Recipe) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header with dot divider and add button
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 6, height: 6)
                    
                    Text(title)
                        .font(.custom("Inter-Regular", size: 14))
                        .kerning(1)
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                }
                
                Spacer()
                
                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                        Text("Add")
                            .font(.custom("Inter-Regular", size: 14))
                    }
                    .foregroundColor(Color(red: 1, green: 0.48, blue: 0.18))
                }
            }
            
            // Meal card or empty state
            if let recipe = recipe {
                MealCardView(recipe: recipe, onDetail: onDetail)
            } else {
                EmptyMealCard(onAdd: onAdd)
            }
        }
    }
}

struct MealCardView: View {
    let recipe: Recipe
    let onDetail: (Recipe) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Meal image with fork overlay
            ZStack(alignment: .topTrailing) {
                if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                    // Display image from Supabase URL
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            // Loading state
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
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
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        case .failure(_):
                            // Failed to load, show placeholder
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    // No image available, show placeholder
                    placeholderView
                }
                
                // Fork positioned in corner
                Image("fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .offset(x: -8, y: 120)
            }
            
            // Meal details
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.primary)
                
                Text("\(recipe.prepTime) min · \(recipe.calories) Kcal")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.secondary)
                
                // Nutrient tags
                HStack(spacing: 8) {
                    NutrientTag(value: "\(recipe.protein)g", label: "Protein", color: Color(red: 0.961, green: 0.914, blue: 0.816)) // #F5E9D0
                    NutrientTag(value: "\(recipe.carbs)g", label: "Carbs", color: Color(red: 0.890, green: 0.890, blue: 0.890)) // #E3E3E3
                    NutrientTag(value: "\(recipe.calories)", label: "Fat", color: Color(red: 0.933, green: 0.906, blue: 0.973)) // #EEE7F8
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onDetail(recipe)
        }
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .cornerRadius(12)
            .overlay(
                VStack {
                    Image("fork.knife")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.secondary)
                    Text("Meal Image")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            )
    }
}

struct NutrientTag: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.custom("Inter-Bold", size: 12))
            Text(label)
                .font(.custom("Inter-Regular", size: 12))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color)
        .cornerRadius(12)
    }
}

struct EmptyMealCard: View {
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(red: 1, green: 0.48, blue: 0.18))
                
                Text("Add meal")
                    .font(Font.custom("Inter", size: 14).weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Grocery List

struct GroceryListView: View {
    let selectedDate: Date
    @EnvironmentObject var appState: AppState
    
    @State private var groceryItems: [GroceryItem] = []
    @State private var isLoading: Bool = false
    
    // Computed property to generate grocery list from day's recipes
    private func updateGroceryItems() {
        Task {
            await loadGroceryItems()
        }
    }
    
    private func loadGroceryItems() async {
        await MainActor.run {
            isLoading = true
        }
        
        let plan = appState.mealPlan(for: selectedDate)
        var ingredientMap: [String: AggregatedIngredient] = [:]
        
        // Collect ingredients from all meals
        let meals = [plan.breakfast, plan.lunch, plan.dinner].compactMap { $0 }
        
        for meal in meals {
            // Fetch detailed recipe data if ingredients are empty
            var detailedRecipe = meal
            if meal.ingredients.isEmpty {
                if let fetchedRecipe = await appState.fetchRecipeDetails(for: meal.id) {
                    detailedRecipe = fetchedRecipe
                }
            }
            
            for ingredient in detailedRecipe.groceryListIngredients {
                let key = ingredient.name.lowercased()
                if let existing = ingredientMap[key] {
                    // Aggregate quantities
                    ingredientMap[key] = existing.adding(ingredient)
                } else {
                    // First occurrence
                    ingredientMap[key] = AggregatedIngredient(
                        name: ingredient.name,
                        quantityValue: ingredient.quantityValue,
                        quantityUnit: ingredient.quantityUnit,
                        recipes: [detailedRecipe.name],
                        recipeImageURLs: [detailedRecipe.imageURL ?? ""],
                        recipeNames: [detailedRecipe.name]
                    )
                }
            }
        }
        
        // Convert to GroceryItem array, using persistent completion states
        let newItems = ingredientMap.values.map { aggregated in
            return GroceryItem(
                name: aggregated.name,
                amount: aggregated.displayAmount,
                isCompleted: appState.getGroceryItemCompletion(ingredientName: aggregated.name),
                hasImage: !aggregated.recipeImageURLs.isEmpty && aggregated.recipeImageURLs.first != "",
                subtitle: aggregated.recipes.count > 1 ? "Used in \(aggregated.recipes.count) recipes" : aggregated.recipes.first,
                recipeImageURL: aggregated.recipeImageURLs.first,
                recipeName: aggregated.recipeNames.first
            )
        }.sorted { $0.name < $1.name }
        
        await MainActor.run {
            groceryItems = newItems
            isLoading = false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and share button
            HStack {
                Text("GROCERY LIST")
                    .font(.custom("Inter-Bold", size: 14))
                    .kerning(1)
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                
                Spacer()
                
                if !groceryItems.isEmpty {
                    Button(action: shareGroceryList) {
                        HStack(spacing: 4) {
                            Image("send")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            Text("Share list")
                                .font(.custom("Inter-Regular", size: 14))
                        }
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.5)) // #6B7280
                    }
                }
            }
            
            // Grocery items or empty state
            if isLoading {
                VStack(spacing: 12) {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading ingredients...")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color.gray.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            } else if groceryItems.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "cart")
                            .font(.system(size: 24))
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("No ingredients needed")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color.gray.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            } else {
                VStack(spacing: 8) {
                    ForEach($groceryItems) { $item in
                        GroceryItemCard(item: $item)
                    }
                }
            }
        }
        .onAppear {
            updateGroceryItems()
        }
        .onChange(of: selectedDate) { _, _ in
            updateGroceryItems()
        }
        .onChange(of: appState.dailyMealPlans) { _, _ in
            // Update grocery list when meal plans change
            updateGroceryItems()
        }
    }
    
    private func shareGroceryList() {
        // Filter out checked items and create bullet-point list of unchecked grocery items only
        let uncheckedItems = groceryItems.filter { !$0.isCompleted }
        let groceryList = uncheckedItems.map { item in
            "• \(item.name): \(item.amount)"
        }.joined(separator: "\n")
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: selectedDate)
        
        // Create the full message
        let message = """
        Grocery list for \(dateString):
        
        \(groceryList)
        """
        
        // Share the grocery list
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

// Helper struct for aggregating ingredients
struct AggregatedIngredient {
    let name: String
    let quantityValue: Float?
    let quantityUnit: String?
    let recipes: [String]
    let recipeImageURLs: [String] // Add recipe image URLs
    let recipeNames: [String] // Add recipe names
    
    var displayAmount: String {
        if let value = quantityValue, let unit = quantityUnit {
            let formattedValue = formatQuantityValue(value)
            return "\(formattedValue) \(unit)"
        } else if let value = quantityValue {
            let formattedValue = formatQuantityValue(value)
            return formattedValue
        } else {
            return "To taste"
        }
    }
    
    // Helper function to format quantity values
    private func formatQuantityValue(_ value: Float) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            // If it's a whole number, show as integer
            return "\(Int(value))"
        } else {
            // If it has decimal places, show as float but remove trailing zeros
            return String(format: "%.1f", value).replacingOccurrences(of: ".0", with: "")
        }
    }
    
    func adding(_ ingredient: Ingredient) -> AggregatedIngredient {
        // For now, just return the first recipe's image and name
        // In a more sophisticated implementation, you might want to show multiple images
        return AggregatedIngredient(
            name: self.name,
            quantityValue: (self.quantityValue ?? 0) + (ingredient.quantityValue ?? 0),
            quantityUnit: self.quantityUnit,
            recipes: self.recipes,
            recipeImageURLs: self.recipeImageURLs,
            recipeNames: self.recipeNames
        )
    }
}

struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    var isCompleted: Bool
    var hasImage: Bool = false
    var subtitle: String? = nil
    var recipeImageURL: String? = nil // Add recipe image URL
    var recipeName: String? = nil // Add recipe name for better context
}

struct QuantityDropdown: View {
    let value: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(["300g", "500g", "1kg", "2 medium", "4", "1 can"], id: \.self) { option in
                        Button(action: {
                            // Handle quantity selection
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }) {
                            Text(option)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }
}

struct GroceryItemCard: View {
    @Binding var item: GroceryItem
    @State private var isExpanded: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 12) {
                // Checkbox
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        item.isCompleted.toggle()
                        // Save the completion state to persistent storage
                        appState.updateGroceryItemCompletion(ingredientName: item.name, isCompleted: item.isCompleted)
                    }
                }) {
                    Image(item.isCompleted ? "tick-circle-filled" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(item.isCompleted ? .green : Color.gray.opacity(0.2))
                }
                
                // Item content
                VStack(alignment: .leading, spacing: 4) {
                    // Item name
                    Text(item.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                        .strikethrough(item.isCompleted)
                }
                
                Spacer()
                
                // Amount and chevron - larger tappable area
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(item.amount)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, isExpanded ? 8 : 16)
            
            // Expanded accordion panel
            if isExpanded {
                HStack(alignment: .center, spacing: 16) {
                    // Recipe Image - show real recipe image if available, otherwise placeholder
                    if let imageURL = item.recipeImageURL, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                // Loading state
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.6)
                                            .progressViewStyle(CircularProgressViewStyle())
                                    )
                            case .success(let image):
                                // Successfully loaded image
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure(_):
                                // Failed to load, show placeholder
                                placeholderView
                            @unknown default:
                                placeholderView
                            }
                        }
                    } else {
                        // No image available, show placeholder
                        placeholderView
                    }
                    
                    // Recipe Name (show item name if no subtitle)
                    Text(item.subtitle ?? "Recipe using \(item.name)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .opacity(item.isCompleted ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: item.isCompleted)
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray5))
            .frame(width: 40, height: 40)
            .overlay(
                Image("fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.secondary)
            )
    }
}

// MARK: - Sheet Views (reused from original)
// Note: MealSuggestionSheet and RecipeDetailSheet are defined in WeeklyPlannerView.swift

// MARK: - MealLoggedBanner

struct MealLoggedBanner: View {
    let image: UIImage
    let time: String
    let points: Int
    @Binding var isVisible: Bool
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Logged at \(time) · Earned \(points) pts 🎉")
                    .font(.custom("Inter_18pt-Regular", size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(12)
            .background(Color(red: 1, green: 0.96, blue: 0.82))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 8)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.4), value: isVisible)
        }
    }
}

// MARK: - Generate Meals Banner

struct GenerateMealsBanner: View {
    let selectedDate: Date
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Generate meals")
                    .font(.custom("Inter", size: 16).weight(.bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Text("The AI will cover your day.")
                    .font(.custom("Inter", size: 14))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            
            Spacer()
            
            Button(action: {
                appState.generateMealPlan(for: selectedDate)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                    Text("Generate")
                        .font(.custom("Inter", size: 14).weight(.medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 1, green: 0.48, blue: 0.18))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    DiaryView()
        .environmentObject(AppState())
} 

