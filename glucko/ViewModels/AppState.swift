import Foundation
import Combine
import SwiftUI
// import Supabase

class AppState: ObservableObject {
    // Temporarily disabled to prevent crash
    // let supabase = SupabaseClient(
    //     supabaseURL: URL(string: "https://paafbaftnlwhboshwwxf.supabase.co")!,
    //     supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    // )
    @Published var dailyMealPlans: [String: DailyMealPlan] = [:]
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var recipes: [Recipe] = [] // Changed from sampleRecipes to recipes
    @Published var userPoints: Int = 0
    @Published var streak: Int = 0
    @Published var isPartnerConnected: Bool = false
    @Published var loggedMeals: [LoggedMeal] = []
    @Published var groceryListCompletionStates: [String: Bool] = [:] // Store completion states by ingredient name and date
    
    // Scan Flow State
    @Published var scanFlowState: ScanFlowState = .tips
    @Published var capturedImageName: String? // Using image name instead of UIImage
    @Published var hiddenIngredients: String = ""
    @Published var currentRecipe: Recipe?
    @Published var selectedMealType: MealType = .lunch
    @Published var isAnalyzing: Bool = false
    @Published var favoriteRecipeIds: Set<UUID> = [] // Track favorite recipe IDs

    init() {
        // Initialize with empty recipes, then fetch from Supabase
        self.recipes = []
        print("🔍 AppState initialized, fetching recipes from Supabase...")
        
        // Load logged meals from local storage first (fallback)
        loadLoggedMeals()
        
        // Load grocery list completion states
        loadGroceryListCompletionStates()
        
        // Then try to load from Supabase
        Task {
            await fetchLoggedMealsFromSupabase()
        }
        
        Task {
            await fetchRecipes()
        }
    }

    // MARK: - Recipe Methods
    
    @MainActor
    func fetchRecipes() async {
        do {
            print("🔍 Fetching recipes from Supabase...")
            
            // Create URL request to Supabase
            let url = URL(string: "https://paafbaftnlwhboshwwxf.supabase.co/rest/v1/recipes?select=*")!
            var request = URLRequest(url: url)
            request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "apikey")
            request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let supabaseRecipes = try JSONDecoder().decode([SupabaseRecipe].self, from: data)
                
                // Convert Supabase recipes to Recipe objects
                self.recipes = supabaseRecipes.map { supabaseRecipe in
                    Recipe(
                        id: supabaseRecipe.id,
                        name: supabaseRecipe.name,
                        prepTime: supabaseRecipe.prep_minutes,
                        tags: [], // We'll add tags later
                        description: supabaseRecipe.description ?? "",
                        ingredients: [], // We'll fetch ingredients separately
                        instructions: [], // We'll fetch instructions separately
                        protein: supabaseRecipe.protein,
                        carbs: supabaseRecipe.carbs,
                        fat: supabaseRecipe.fats,
                        calories: supabaseRecipe.calories,
                        imageName: nil,
                        imageURL: supabaseRecipe.image_url,
                        isFavorite: self.favoriteRecipeIds.contains(supabaseRecipe.id)
                    )
                }
                
                print("✅ Successfully loaded \(self.recipes.count) recipes from Supabase")
                for (index, recipe) in self.recipes.enumerated() {
                    print("  \(index + 1). \(recipe.name)")
                }
            } else {
                print("❌ Failed to fetch recipes from Supabase")
                // Fallback to sample recipes
                self.recipes = sampleRecipes
            }
        } catch {
            print("❌ Error fetching recipes: \(error)")
            // Fallback to sample recipes
            self.recipes = sampleRecipes
        }
    }
    
    func fetchRecipeDetails(for recipeId: UUID) async -> Recipe? {
        do {
            print("🔍 Fetching detailed recipe data for ID: \(recipeId)")
            
            // First, get the basic recipe data
            let recipeUrl = URL(string: "https://paafbaftnlwhboshwwxf.supabase.co/rest/v1/recipes?select=*&id=eq.\(recipeId)")!
            var recipeRequest = URLRequest(url: recipeUrl)
            recipeRequest.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "apikey")
            recipeRequest.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "Authorization")
            
            let (recipeData, recipeResponse) = try await URLSession.shared.data(for: recipeRequest)
            
            guard let httpResponse = recipeResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Failed to fetch recipe data")
                return nil
            }
            
            let supabaseRecipes = try JSONDecoder().decode([SupabaseRecipe].self, from: recipeData)
            guard let supabaseRecipe = supabaseRecipes.first else {
                print("❌ Recipe not found")
                return nil
            }
            
            // Get ingredients for this recipe
            let ingredientsUrl = URL(string: "https://paafbaftnlwhboshwwxf.supabase.co/rest/v1/recipe_ingredients?select=amount,quantity_value,quantity_unit,is_optional,show_in_list,ingredients(name)&recipe_id=eq.\(recipeId)")!
            var ingredientsRequest = URLRequest(url: ingredientsUrl)
            ingredientsRequest.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "apikey")
            ingredientsRequest.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "Authorization")
            
            let (ingredientsData, ingredientsResponse) = try await URLSession.shared.data(for: ingredientsRequest)
            
            var ingredients: [Ingredient] = []
            if let ingredientsHttpResponse = ingredientsResponse as? HTTPURLResponse, ingredientsHttpResponse.statusCode == 200 {
                let ingredientsJson = try JSONSerialization.jsonObject(with: ingredientsData) as? [[String: Any]] ?? []
                
                for ingredientData in ingredientsJson {
                    if let amount = ingredientData["amount"] as? String,
                       let ingredientsInfo = ingredientData["ingredients"] as? [String: Any],
                       let name = ingredientsInfo["name"] as? String {
                        
                        let quantityValue = ingredientData["quantity_value"] as? Float
                        let quantityUnit = ingredientData["quantity_unit"] as? String
                        let isOptional = ingredientData["is_optional"] as? Bool ?? false
                        let showInList = ingredientData["show_in_list"] as? Bool ?? true
                        
                        let ingredient = Ingredient(
                            name: name,
                            quantityValue: quantityValue,
                            quantityUnit: quantityUnit,
                            isOptional: isOptional,
                            showInList: showInList
                        )
                        ingredients.append(ingredient)
                    }
                }
            }
            
            // Get preparation steps for this recipe
            let stepsUrl = URL(string: "https://paafbaftnlwhboshwwxf.supabase.co/rest/v1/preparation_steps?select=step_number,instruction&recipe_id=eq.\(recipeId)&order=step_number.asc")!
            var stepsRequest = URLRequest(url: stepsUrl)
            stepsRequest.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "apikey")
            stepsRequest.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "Authorization")
            
            let (stepsData, stepsResponse) = try await URLSession.shared.data(for: stepsRequest)
            
            var instructions: [String] = []
            if let stepsHttpResponse = stepsResponse as? HTTPURLResponse, stepsHttpResponse.statusCode == 200 {
                let stepsJson = try JSONSerialization.jsonObject(with: stepsData) as? [[String: Any]] ?? []
                
                for stepData in stepsJson {
                    if let instruction = stepData["instruction"] as? String {
                        instructions.append(instruction)
                    }
                }
            }
            
            let recipe = Recipe(
                id: supabaseRecipe.id,
                name: supabaseRecipe.name,
                prepTime: supabaseRecipe.prep_minutes,
                tags: [], // We'll add tags later
                description: supabaseRecipe.description ?? "",
                ingredients: ingredients,
                instructions: instructions,
                protein: supabaseRecipe.protein,
                carbs: supabaseRecipe.carbs,
                fat: supabaseRecipe.fats,
                calories: supabaseRecipe.calories,
                imageName: nil,
                imageURL: supabaseRecipe.image_url
            )
            
            print("✅ Successfully fetched recipe details for: \(recipe.name)")
            print("📝 Ingredients: \(ingredients.count)")
            print("📋 Instructions: \(instructions.count)")
            
            return recipe
            
        } catch {
            print("❌ Error fetching recipe details: \(error)")
            return nil
        }
    }
    
    // Temporarily disabled to prevent crash
    // func fetchRecipeDetails(for recipeId: UUID) async -> Recipe? {
    //     do {
    //         print("🔍 Fetching detailed recipe data for ID: \(recipeId)")
    //         let response: [SupabaseRecipeWithDetails] = try await supabase
    //             .from("recipes")
    //             .select("""
    //                 *,
    //                 recipe_ingredients(
    //                     amount,
    //                     ingredients(name)
    //                 ),
    //                 preparation_steps(
    //                     step_number,
    //                     instruction
    //                 )
    //             """)
    //             .eq("id", value: recipeId)
    //             .execute()
    //             .value
    //         
    //         guard let supabaseRecipe = response.first else {
    //             print("❌ Recipe not found")
    //             return nil
    //         }
    //         
    //         // Convert ingredients
    //         let ingredients: [String] = supabaseRecipe.recipe_ingredients?.compactMap { recipeIngredient in
    //             guard let ingredientName = recipeIngredient.ingredients?.name else { return nil }
    //             return "\(recipeIngredient.amount) \(ingredientName)"
    //         } ?? []
    //         
    //         // Convert instructions
    //         let instructions = supabaseRecipe.preparation_steps?
    //             .sorted { $0.step_number < $1.step_number }
    //             .map { $0.instruction } ?? []
    //         
    //         let recipe = Recipe(
    //             id: supabaseRecipe.id,
    //             name: supabaseRecipe.name,
    //             prepTime: supabaseRecipe.prep_minutes,
    //             tags: [], // We'll need to add tags to the database
    //             description: supabaseRecipe.description ?? "",
    //             ingredients: ingredients,
    //             instructions: instructions,
    //             protein: supabaseRecipe.protein,
    //             carbs: supabaseRecipe.carbs,
    //             fat: supabaseRecipe.fats,
    //             calories: supabaseRecipe.calories,
    //             imageName: nil,
    //             imageURL: supabaseRecipe.image_url
    //         )
    //         
    //         print("✅ Fetched recipe details for: \(recipe.name)")
    //         print("📝 Ingredients: \(ingredients)")
    //         print("📋 Instructions: \(instructions)")
    //         
    //         return recipe
    //     } catch {
    //         print("❌ Error fetching recipe details: \(error)")
    //         return sampleRecipes.first { $0.id == recipeId }
    //     }
    // }
    
    // MARK: - Supabase Storage Methods (Temporarily disabled)
    
    func uploadRecipeImage(imageData: Data, recipeId: UUID) async -> String? {
        // Temporarily disabled until Supabase API is fixed
        print("Image upload temporarily disabled")
        return nil
    }
    
    func updateRecipeImageURL(recipeId: UUID, imageURL: String) async {
        // Temporarily disabled until Supabase API is fixed
        print("Recipe image URL update temporarily disabled")
    }

    func ensureMealPlan(for date: Date) {
        let key = Self.dateKey(for: date)
        if dailyMealPlans[key] == nil {
            // Create an empty meal plan - don't auto-populate with recipes
            let plan = DailyMealPlan()
            dailyMealPlans[key] = plan
        }
    }

    func mealPlan(for date: Date) -> DailyMealPlan {
        let key = Self.dateKey(for: date)
        return dailyMealPlans[key] ?? DailyMealPlan()
    }

    func setMealPlan(_ plan: DailyMealPlan, for date: Date) {
        let key = Self.dateKey(for: date)
        dailyMealPlans[key] = plan
    }
    
    // MARK: - Meal Management Methods
    
    func addMeal(_ recipe: Recipe, for date: Date, mealType: MealType) {
        var plan = mealPlan(for: date)
        switch mealType {
        case .breakfast:
            plan.breakfast = recipe
        case .lunch:
            plan.lunch = recipe
        case .dinner:
            plan.dinner = recipe
        }
        setMealPlan(plan, for: date)
    }
    
    func removeMeal(for date: Date, mealType: MealType) {
        var plan = mealPlan(for: date)
        switch mealType {
        case .breakfast:
            plan.breakfast = nil
        case .lunch:
            plan.lunch = nil
        case .dinner:
            plan.dinner = nil
        }
        setMealPlan(plan, for: date)
    }
    
    func swapMeal(for date: Date, mealType: MealType) {
        // Get a random recipe from the database (excluding the current one)
        let currentRecipe = getCurrentMeal(for: date, mealType: mealType)
        let availableRecipes = recipes.filter { $0.id != currentRecipe?.id }
        
        if let newRecipe = availableRecipes.randomElement() {
            addMeal(newRecipe, for: date, mealType: mealType)
        }
    }
    
    func deleteAllMeals(for date: Date) {
        let key = Self.dateKey(for: date)
        dailyMealPlans[key] = DailyMealPlan()
    }
    
    // MARK: - Favorites Management
    
    func toggleFavorite(for recipe: Recipe) {
        if favoriteRecipeIds.contains(recipe.id) {
            favoriteRecipeIds.remove(recipe.id)
        } else {
            favoriteRecipeIds.insert(recipe.id)
        }
        
        // Update the recipe's isFavorite property
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite = favoriteRecipeIds.contains(recipe.id)
        }
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        return favoriteRecipeIds.contains(recipe.id)
    }
    
    var favoriteRecipes: [Recipe] {
        return recipes.filter { favoriteRecipeIds.contains($0.id) }
    }
    
    // MARK: - Meal Plan Generation
    
    func generateMealPlan(for date: Date) {
        guard !recipes.isEmpty else {
            print("❌ No recipes available for meal plan generation")
            return
        }
        
        print("🎯 Generating meal plan for \(Self.dateKey(for: date))")
        
        // Get available recipes (excluding any already used in this day)
        let currentPlan = mealPlan(for: date)
        let usedRecipeIds = Set([
            currentPlan.breakfast?.id,
            currentPlan.lunch?.id,
            currentPlan.dinner?.id
        ].compactMap { $0 })
        
        let availableRecipes = recipes.filter { !usedRecipeIds.contains($0.id) }
        
        guard availableRecipes.count >= 3 else {
            print("❌ Not enough recipes available (need at least 3, have \(availableRecipes.count))")
            return
        }
        
        // Create a new meal plan
        var newPlan = DailyMealPlan()
        
        // Randomly select recipes for each meal type
        let shuffledRecipes = availableRecipes.shuffled()
        
        // Assign breakfast (first recipe)
        newPlan.breakfast = shuffledRecipes[0]
        
        // Assign lunch (second recipe, if different from breakfast)
        if shuffledRecipes.count > 1 {
            newPlan.lunch = shuffledRecipes[1]
        }
        
        // Assign dinner (third recipe, if different from lunch and breakfast)
        if shuffledRecipes.count > 2 {
            newPlan.dinner = shuffledRecipes[2]
        }
        
        // Save the generated meal plan
        setMealPlan(newPlan, for: date)
        
        print("✅ Generated meal plan:")
        print("   🍳 Breakfast: \(newPlan.breakfast?.name ?? "None")")
        print("   🍽️ Lunch: \(newPlan.lunch?.name ?? "None")")
        print("   🍴 Dinner: \(newPlan.dinner?.name ?? "None")")
    }
    
    func generateWeeklyMealPlan() {
        guard !recipes.isEmpty else {
            print("❌ No recipes available for weekly meal plan generation")
            return
        }
        
        print("🎯 Generating weekly meal plan...")
        
        // Use a calendar that starts the week on Monday
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let today = Date()
        // Find the most recent Monday (start of the week)
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday + 5) % 7 // 0 if Monday, 1 if Tuesday, ..., 6 if Sunday
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) ?? today
        
        // Track used recipes across the week to avoid duplicates
        var usedRecipeIds = Set<UUID>()
        
        // Generate meal plans for the next 7 days (Monday to Sunday)
        for dayOffset in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? today
            
            // Get available recipes (excluding already used ones)
            let availableRecipes = recipes.filter { !usedRecipeIds.contains($0.id) }
            
            // If we don't have enough unique recipes, reset and use all recipes
            let recipesToUse = availableRecipes.count >= 3 ? availableRecipes : recipes
            
            // Create a new meal plan for this day
            var newPlan = DailyMealPlan()
            let shuffledRecipes = recipesToUse.shuffled()
            
            // Assign meals (ensure we have at least 3 recipes)
            if shuffledRecipes.count > 0 {
                newPlan.breakfast = shuffledRecipes[0]
                usedRecipeIds.insert(shuffledRecipes[0].id)
            }
            if shuffledRecipes.count > 1 {
                newPlan.lunch = shuffledRecipes[1]
                usedRecipeIds.insert(shuffledRecipes[1].id)
            }
            if shuffledRecipes.count > 2 {
                newPlan.dinner = shuffledRecipes[2]
                usedRecipeIds.insert(shuffledRecipes[2].id)
            }
            
            // Save the meal plan for this day
            setMealPlan(newPlan, for: targetDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayName = dateFormatter.string(from: targetDate)
            
            print("✅ Generated meal plan for \(dayName):")
            print("   🍳 Breakfast: \(newPlan.breakfast?.name ?? "None")")
            print("   🍽️ Lunch: \(newPlan.lunch?.name ?? "None")")
            print("   🍴 Dinner: \(newPlan.dinner?.name ?? "None")")
        }
        
        print("🎉 Weekly meal plan generation completed!")
    }
    
    func getCurrentMeal(for date: Date, mealType: MealType) -> Recipe? {
        let plan = mealPlan(for: date)
        switch mealType {
        case .breakfast:
            return plan.breakfast
        case .lunch:
            return plan.lunch
        case .dinner:
            return plan.dinner
        }
    }
    
    func logMeal(_ recipe: Recipe, mealType: MealType, image: UIImage? = nil) {
        let imageData = image?.jpegData(compressionQuality: 0.9)
        let loggedMeal = LoggedMeal(recipe: recipe, mealType: mealType, imageData: imageData)
        loggedMeals.append(loggedMeal)
        userPoints += loggedMeal.pointsEarned
        resetScanFlow()
    }
    
    func resetScanFlow() {
        scanFlowState = .tips
        capturedImageName = nil
        hiddenIngredients = ""
        currentRecipe = nil
        selectedMealType = .lunch
        isAnalyzing = false
    }
    
    func analyzeMeal() {
        isAnalyzing = true
        // Simulate analysis delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isAnalyzing = false
            self.scanFlowState = .mealCategorization
        }
    }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Grocery List Persistence
    
    private func saveGroceryListCompletionStates() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(groceryListCompletionStates)
            UserDefaults.standard.set(data, forKey: "groceryListCompletionStates")
            print("✅ Saved grocery list completion states to UserDefaults")
        } catch {
            print("❌ Failed to save grocery list completion states: \(error)")
        }
    }
    
    private func loadGroceryListCompletionStates() {
        guard let data = UserDefaults.standard.data(forKey: "groceryListCompletionStates") else {
            print("📝 No saved grocery list completion states found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let loadedStates = try decoder.decode([String: Bool].self, from: data)
            groceryListCompletionStates = loadedStates
            print("✅ Loaded grocery list completion states from UserDefaults")
        } catch {
            print("❌ Failed to load grocery list completion states: \(error)")
            groceryListCompletionStates = [:]
        }
    }
    
    // Public method to update grocery item completion state
    func updateGroceryItemCompletion(ingredientName: String, isCompleted: Bool) {
        groceryListCompletionStates[ingredientName.lowercased()] = isCompleted
        saveGroceryListCompletionStates()
        print("✅ Updated grocery item completion: \(ingredientName) = \(isCompleted)")
    }
    
    // Public method to get grocery item completion state
    func getGroceryItemCompletion(ingredientName: String) -> Bool {
        return groceryListCompletionStates[ingredientName.lowercased()] ?? false
}

// MARK: - Supabase Data Models

struct SupabaseRecipe: Codable {
    let id: UUID
    let name: String
    let prep_minutes: Int
    let description: String?
    let protein: Int
    let carbs: Int
    let fats: Int
    let calories: Int
    let created_at: String?
    let updated_at: String?
    let image_url: String?
}

// struct SupabaseRecipeWithDetails: Codable {
//     let id: UUID
//     let name: String
//     let prep_minutes: Int
//     let description: String?
//     let protein: Int
//     let carbs: Int
//     let fats: Int
//     let calories: Int
//     let image_url: String?
//     let recipe_ingredients: [SupabaseRecipeIngredient]?
//     let preparation_steps: [SupabasePreparationStep]?
//     
//     enum CodingKeys: String, CodingKey {
//         case id, name, prep_minutes, description, protein, carbs, fats, calories, image_url, preparation_steps
//         case recipe_ingredients = "recipe_ingredients"
//     }
// }

// struct SupabaseRecipeIngredient: Codable {
//     let amount: String
//     let ingredients: SupabaseIngredient?
// }

// struct SupabaseIngredient: Codable {
//     let name: String
// }

// struct SupabasePreparationStep: Codable {
//     let step_number: Int
//     let instruction: String
// }

    struct SupabaseLoggedMeal: Codable {
        let id: UUID
        let recipe_id: UUID
        let recipe_name: String
        let meal_type: String
        let logged_at: String
        let points_earned: Int
        let image_data: String?
        
        enum CodingKeys: String, CodingKey {
            case id, recipe_id, recipe_name, meal_type, logged_at, points_earned, image_data
        }
    }

// MARK: - Sample Recipes (Fallback)
var sampleRecipes: [Recipe] {
    [
        Recipe(
            name: "Quick Chickpea Stew",
            prepTime: 10,
            tags: ["Vegetarian", "Protein", "Fiber"],
            description: "A hearty and nutritious chickpea stew with tomatoes and yogurt",
            ingredients: [
                Ingredient(name: "Chickpeas", quantityValue: 400, quantityUnit: "g", isOptional: false, showInList: true),
                Ingredient(name: "Tomatoes", quantityValue: 2, quantityUnit: "medium", isOptional: false, showInList: true),
                Ingredient(name: "Red onion", quantityValue: 1, quantityUnit: "small", isOptional: false, showInList: true),
                Ingredient(name: "Garlic", quantityValue: 2, quantityUnit: "cloves", isOptional: false, showInList: true),
                Ingredient(name: "Yogurt", quantityValue: 2, quantityUnit: "tablespoons", isOptional: false, showInList: true),
                Ingredient(name: "Olive oil", quantityValue: 1, quantityUnit: "tablespoon", isOptional: false, showInList: true)
            ],
            instructions: [
                "Heat oil in a large pot over medium heat",
                "Sauté onion and garlic until fragrant",
                "Add tomatoes and chickpeas",
                "Simmer for 10 minutes until thickened",
                "Serve with yogurt on top"
            ],
            protein: 12,
            carbs: 45,
            fat: 8,
            calories: 320,
            imageName: "quick_chickpea_stew"
        ),
        Recipe(
            name: "Grilled Chicken Salad",
            prepTime: 15,
            tags: ["Protein", "Healthy", "Low-carb"],
            description: "Fresh and healthy grilled chicken salad with mixed greens",
            ingredients: [
                Ingredient(name: "Chicken breast", quantityValue: 200, quantityUnit: "g", isOptional: false, showInList: true),
                Ingredient(name: "Mixed greens", quantityValue: 100, quantityUnit: "g", isOptional: false, showInList: true),
                Ingredient(name: "Cherry tomatoes", quantityValue: 1, quantityUnit: "cup", isOptional: false, showInList: true),
                Ingredient(name: "Olive oil", quantityValue: 1, quantityUnit: "tablespoon", isOptional: false, showInList: true),
                Ingredient(name: "Lemon juice", quantityValue: 1, quantityUnit: "tablespoon", isOptional: false, showInList: true)
            ],
            instructions: [
                "Season chicken breast with salt and pepper",
                "Grill chicken for 6-8 minutes per side until cooked through",
                "Let chicken rest for 5 minutes, then slice",
                "Toss mixed greens with olive oil and lemon juice",
                "Top with sliced chicken and cherry tomatoes"
            ],
            protein: 25,
            carbs: 8,
            fat: 12,
            calories: 280,
            imageName: "grilled_chicken_salad"
            )
        ]
    }

    // MARK: - Helper Functions for Image Upload
    
    func addChickpeaStewImage() async {
        // This function will help you upload the chickpea stew image
        // You'll need to provide the image data from your assets
        
        let recipeId = UUID(uuidString: "ea194339-6c1c-4dd3-a304-97c3c3a798e9")!
        
        // For now, we'll just print instructions
        print("""
        🍲 To add the chickpea stew image to Supabase:
        
        1. Go to your Supabase Dashboard
        2. Navigate to Storage > Create a new bucket called "recipe-images"
        3. Set the bucket to public
        4. Upload the chickpea stew image with filename: \(recipeId.uuidString).jpg
        5. Copy the public URL
        6. Update your recipe in the database with the image_url field
        
        Recipe ID: \(recipeId)
        Expected filename: \(recipeId.uuidString).jpg
        """)
    }
    
    func testImageURL() async {
        let imageURL = "https://paafbaftnlwhboshwwxf.supabase.co/storage/v1/object/public/recipe-images//ea194339-6c1c-4dd3-a304-97c3c3a798e9.png"
        
        print("🔍 Testing image URL accessibility...")
        print("📱 URL: \(imageURL)")
        
        // Test if the URL is valid
        guard let url = URL(string: imageURL) else {
            print("❌ Invalid URL format")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ HTTP Status: \(httpResponse.statusCode)")
                print("📊 Data size: \(data.count) bytes")
                
                if httpResponse.statusCode == 200 {
                    print("✅ Image URL is accessible!")
                } else {
                    print("❌ Image URL returned status code: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("❌ Error testing image URL: \(error)")
        }
    }
    
    // MARK: - Logged Meals Persistence
    
    private func saveLoggedMeals() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(loggedMeals)
            UserDefaults.standard.set(data, forKey: "loggedMeals")
            print("✅ Saved \(loggedMeals.count) logged meals to UserDefaults")
        } catch {
            print("❌ Failed to save logged meals: \(error)")
        }
    }
    
    private func loadLoggedMeals() {
        guard let data = UserDefaults.standard.data(forKey: "loggedMeals") else {
            print("📝 No saved logged meals found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let loadedMeals = try decoder.decode([LoggedMeal].self, from: data)
            loggedMeals = loadedMeals
            print("✅ Loaded \(loadedMeals.count) logged meals from UserDefaults")
        } catch {
            print("❌ Failed to load logged meals: \(error)")
            loggedMeals = []
        }
    }
    
    // Public method to add a logged meal and save it
    func addLoggedMeal(_ meal: LoggedMeal) {
        loggedMeals.append(meal)
        saveLoggedMeals()
        print("✅ Added logged meal: \(meal.recipe.name) for \(meal.mealType.displayName)")
    }
    
    // MARK: - Supabase Logged Meals Storage
    
    @MainActor
    func saveLoggedMealToSupabase(_ meal: LoggedMeal) async {
        do {
            print("🔍 Saving logged meal to Supabase: \(meal.recipe.name)")
            
            // Convert LoggedMeal to SupabaseLoggedMeal
            let supabaseMeal = SupabaseLoggedMeal(
                id: meal.id,
                recipe_id: meal.recipe.id,
                recipe_name: meal.recipe.name,
                meal_type: meal.mealType.rawValue,
                logged_at: ISO8601DateFormatter().string(from: meal.loggedAt),
                points_earned: meal.pointsEarned,
                image_data: meal.imageData?.base64EncodedString()
            )
            
            // Create URL request to Supabase
            let url = URL(string: "https://paafbaftnlwhboshwwxf.supabase.co/rest/v1/logged_meals")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "apikey")
            request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "Authorization")
            
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(supabaseMeal)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("✅ Successfully saved logged meal to Supabase")
                
                // Also save locally as backup
                addLoggedMeal(meal)
            } else {
                print("❌ Failed to save logged meal to Supabase, status: \(response)")
                // Fallback to local storage only
                addLoggedMeal(meal)
            }
        } catch {
            print("❌ Error saving logged meal to Supabase: \(error)")
            // Fallback to local storage only
            addLoggedMeal(meal)
        }
    }
    
    @MainActor
    func fetchLoggedMealsFromSupabase() async {
        do {
            print("🔍 Fetching logged meals from Supabase...")
            
            // Create URL request to Supabase
            let url = URL(string: "https://paafbaftnlwhboshwwxf.supabase.co/rest/v1/logged_meals?select=*&order=logged_at.desc")!
            var request = URLRequest(url: url)
            request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "apikey")
            request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let supabaseMeals = try JSONDecoder().decode([SupabaseLoggedMeal].self, from: data)
                
                // Convert SupabaseLoggedMeal to LoggedMeal
                self.loggedMeals = supabaseMeals.compactMap { supabaseMeal in
                    guard let mealType = MealType(rawValue: supabaseMeal.meal_type),
                          let loggedAt = ISO8601DateFormatter().date(from: supabaseMeal.logged_at) else {
                        return nil
                    }
                    
                    // Create a placeholder recipe (we could fetch the full recipe if needed)
                    let recipe = Recipe(
                        id: supabaseMeal.recipe_id,
                        name: supabaseMeal.recipe_name,
                        prepTime: 0,
                        tags: [],
                        description: "",
                        ingredients: [],
                        instructions: [],
                        protein: 0,
                        carbs: 0,
                        fat: 0,
                        calories: 0,
                        imageName: nil,
                        imageURL: nil
                    )
                    
                    return LoggedMeal(
                        recipe: recipe,
                        loggedAt: loggedAt,
                        mealType: mealType,
                        pointsEarned: supabaseMeal.points_earned,
                        imageData: supabaseMeal.image_data.flatMap { Data(base64Encoded: $0) }
                    )
                }
                
                print("✅ Successfully loaded \(self.loggedMeals.count) logged meals from Supabase")
            } else {
                print("❌ Failed to fetch logged meals from Supabase, status: \(response)")
                // Fallback to local storage
                loadLoggedMeals()
            }
        } catch {
            print("❌ Error fetching logged meals from Supabase: \(error)")
            // Fallback to local storage
            loadLoggedMeals()
        }
    }
}

enum ScanFlowState {
    case tips
    case camera
    case crop
    case hiddenIngredients
    case analyzing
    case mealCategorization
    case logged
}

extension Date {
    var startOfDay: Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: self)
        return cal.date(from: comps) ?? self
    }
}
