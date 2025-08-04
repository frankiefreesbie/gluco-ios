import Foundation

struct DailyMealPlan: Codable, Hashable {
    var breakfast: Recipe?
    var lunch: Recipe?
    var dinner: Recipe?
} 