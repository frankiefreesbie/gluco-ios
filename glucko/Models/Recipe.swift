
import Foundation

// MARK: - Structured Ingredient Model
struct Ingredient: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let quantityValue: Float?
    let quantityUnit: String?
    let isOptional: Bool
    let showInList: Bool
    
    // Computed property for display
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
    
    // Computed property for grocery list display
    var groceryListDisplay: String {
        if showInList, let value = quantityValue, let unit = quantityUnit {
            let formattedValue = formatQuantityValue(value)
            return "\(name): \(formattedValue) \(unit)"
        } else if showInList, let value = quantityValue {
            let formattedValue = formatQuantityValue(value)
            return "\(name): \(formattedValue)"
        } else {
            return name
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
    
    init(id: UUID = UUID(), name: String, quantityValue: Float? = nil, quantityUnit: String? = nil, isOptional: Bool = false, showInList: Bool = true) {
        self.id = id
        self.name = name
        self.quantityValue = quantityValue
        self.quantityUnit = quantityUnit
        self.isOptional = isOptional
        self.showInList = showInList
    }
    
    // Convenience initializer for backward compatibility
    init(name: String, amount: String) {
        self.id = UUID()
        self.name = name
        
        // Parse the amount string to extract structured data
        let parsed = Self.parseAmount(amount)
        self.quantityValue = parsed.value
        self.quantityUnit = parsed.unit
        self.isOptional = parsed.isOptional
        self.showInList = parsed.showInList
    }
    
    // Static method to parse amount strings
    private static func parseAmount(_ amount: String) -> (value: Float?, unit: String?, isOptional: Bool, showInList: Bool) {
        let lowercased = amount.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check for vague/optional ingredients
        let vaguePatterns = ["to taste", "as needed", "optional", "a pinch", "a dash", "drizzle", "sprinkle", "handful", "few", "some"]
        if vaguePatterns.contains(where: { lowercased.contains($0) }) {
            return (nil, nil, true, false)
        }
        
        // Pattern 1: "2 cloves", "400g", "1.5 cups", "3 medium"
        let pattern1 = #"^(\d+(?:\.\d+)?)\s*(g|kg|ml|l|cloves?|medium|large|small|cups?|tablespoons?|teaspoons?|tbsp|tsp|ounces?|oz|pounds?|lbs?|pieces?|slices?|bunches?|heads?|cans?|packages?|bottles?)$"#
        if let match = lowercased.range(of: pattern1, options: .regularExpression) {
            let components = lowercased.components(separatedBy: .whitespaces)
            if components.count >= 2, let value = Float(components[0]) {
                return (value, components[1], false, true)
            }
        }
        
        // Pattern 2: "2-3 tablespoons", "1-2 medium"
        let pattern2 = #"^(\d+)-(\d+)\s*(g|kg|ml|l|cloves?|medium|large|small|cups?|tablespoons?|teaspoons?|tbsp|tsp|ounces?|oz|pounds?|lbs?|pieces?|slices?|bunches?|heads?|cans?|packages?|bottles?)$"#
        if let match = lowercased.range(of: pattern2, options: .regularExpression) {
            let components = lowercased.components(separatedBy: .whitespaces)
            if components.count >= 2 {
                let rangeComponents = components[0].components(separatedBy: "-")
                if rangeComponents.count == 2,
                   let minValue = Float(rangeComponents[0]),
                   let maxValue = Float(rangeComponents[1]) {
                    let averageValue = (minValue + maxValue) / 2
                    return (averageValue, components[1], false, true)
                }
            }
        }
        
        // Pattern 3: "1/2 cup", "3/4 teaspoon"
        let pattern3 = #"^(\d+)/(\d+)\s*(g|kg|ml|l|cloves?|medium|large|small|cups?|tablespoons?|teaspoons?|tbsp|tsp|ounces?|oz|pounds?|lbs?|pieces?|slices?|bunches?|heads?|cans?|packages?|bottles?)$"#
        if let match = lowercased.range(of: pattern3, options: .regularExpression) {
            let components = lowercased.components(separatedBy: .whitespaces)
            if components.count >= 2 {
                let fractionComponents = components[0].components(separatedBy: "/")
                if fractionComponents.count == 2,
                   let numerator = Float(fractionComponents[0]),
                   let denominator = Float(fractionComponents[1]) {
                    let value = numerator / denominator
                    return (value, components[1], false, true)
                }
            }
        }
        
        // Pattern 4: "400g canned", "2 medium ripe"
        let pattern4 = #"^(\d+(?:\.\d+)?)\s*(g|kg|ml|l|cloves?|medium|large|small|cups?|tablespoons?|teaspoons?|tbsp|tsp|ounces?|oz|pounds?|lbs?|pieces?|slices?|bunches?|heads?|cans?|packages?|bottles?)\s+.+$"#
        if let match = lowercased.range(of: pattern4, options: .regularExpression) {
            let components = lowercased.components(separatedBy: .whitespaces)
            if components.count >= 2, let value = Float(components[0]) {
                return (value, components[1], false, true)
            }
        }
        
        // If no pattern matches, mark as not suitable for grocery list
        return (nil, nil, false, false)
    }
}

struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let prepTime: Int
    let tags: [String]
    let description: String
    let ingredients: [Ingredient] // Updated to use structured Ingredient model
    let instructions: [String]
    let protein: Int
    let carbs: Int
    let fat: Int
    let calories: Int
    var imageName: String? // Optional image name for UI
    var imageURL: String? // Optional URL for Supabase images
    var hiddenIngredients: [String] = [] // For additional ingredients not visible in photo
    var loggedAt: Date? // When the meal was logged
    var mealType: MealType? // Breakfast, Lunch, Dinner
    var isFavorite: Bool = false // New property for favorites
    
    // Computed property for backward compatibility
    var ingredientNames: [String] {
        return ingredients.map { $0.name }
    }
    
    // Computed property for backward compatibility
    var ingredientAmounts: [String] {
        return ingredients.map { $0.displayAmount }
    }
    
    // Computed property for grocery list ingredients
    var groceryListIngredients: [Ingredient] {
        return ingredients.filter { $0.showInList }
    }
    
    init(id: UUID = UUID(), name: String, prepTime: Int, tags: [String], description: String, ingredients: [Ingredient], instructions: [String], protein: Int, carbs: Int, fat: Int, calories: Int, imageName: String? = nil, imageURL: String? = nil, hiddenIngredients: [String] = [], loggedAt: Date? = nil, mealType: MealType? = nil, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.prepTime = prepTime
        self.tags = tags
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.calories = calories
        self.imageName = imageName
        self.imageURL = imageURL
        self.hiddenIngredients = hiddenIngredients
        self.loggedAt = loggedAt
        self.mealType = mealType
        self.isFavorite = isFavorite
    }
    
    // Convenience initializer for backward compatibility
    init(id: UUID = UUID(), name: String, prepTime: Int, tags: [String], description: String, ingredients: [String], ingredientAmounts: [String] = [], instructions: [String], protein: Int, carbs: Int, fat: Int, calories: Int, imageName: String? = nil, imageURL: String? = nil, hiddenIngredients: [String] = [], loggedAt: Date? = nil, mealType: MealType? = nil, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.prepTime = prepTime
        self.tags = tags
        self.description = description
        
        // Convert string arrays to structured ingredients
        var structuredIngredients: [Ingredient] = []
        for (index, ingredientName) in ingredients.enumerated() {
            let amount = index < ingredientAmounts.count ? ingredientAmounts[index] : "1 serving"
            let ingredient = Ingredient(name: ingredientName, amount: amount)
            structuredIngredients.append(ingredient)
        }
        self.ingredients = structuredIngredients
        
        self.instructions = instructions
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.calories = calories
        self.imageName = imageName
        self.imageURL = imageURL
        self.hiddenIngredients = hiddenIngredients
        self.loggedAt = loggedAt
        self.mealType = mealType
        self.isFavorite = isFavorite
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    
    var displayName: String {
        return self.rawValue
    }
}

struct DayPlan: Identifiable {
    let id = UUID()
    let day: String
    var meal: Recipe?
    var isPlanned: Bool = false
}

struct LoggedMeal: Identifiable, Codable {
    let id: UUID
    let recipe: Recipe
    let loggedAt: Date
    let mealType: MealType
    let pointsEarned: Int
    var imageData: Data? // User photo
    
    init(recipe: Recipe, loggedAt: Date = Date(), mealType: MealType, pointsEarned: Int = 120, imageData: Data? = nil) {
        self.id = UUID()
        self.recipe = recipe
        self.loggedAt = loggedAt
        self.mealType = mealType
        self.pointsEarned = pointsEarned
        self.imageData = imageData
    }
    
    // Custom coding keys to handle Data encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, recipe, loggedAt, mealType, pointsEarned, imageData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        recipe = try container.decode(Recipe.self, forKey: .recipe)
        loggedAt = try container.decode(Date.self, forKey: .loggedAt)
        mealType = try container.decode(MealType.self, forKey: .mealType)
        pointsEarned = try container.decode(Int.self, forKey: .pointsEarned)
        
        // Handle Data decoding
        if let imageDataString = try container.decodeIfPresent(String.self, forKey: .imageData) {
            imageData = Data(base64Encoded: imageDataString)
        } else {
            imageData = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(recipe, forKey: .recipe)
        try container.encode(loggedAt, forKey: .loggedAt)
        try container.encode(mealType, forKey: .mealType)
        try container.encode(pointsEarned, forKey: .pointsEarned)
        
        // Handle Data encoding
        if let imageData = imageData {
            try container.encode(imageData.base64EncodedString(), forKey: .imageData)
        }
    }
}

enum CharacterState: String, CaseIterable {
    case tired = "tired"
    case improving = "improving"
    case energized = "energized"
    
    var emoji: String {
        switch self {
        case .tired: return "😴"
        case .improving: return "🙂"
        case .energized: return "⚡"
        }
    }
    
    var message: String {
        switch self {
        case .tired: return "Gluko needs healthy meals to feel better!"
        case .improving: return "Gluko is feeling more energetic!"
        case .energized: return "Gluko is thriving! Keep it up!"
        }
    }
}
