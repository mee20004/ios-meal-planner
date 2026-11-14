import Foundation

enum MealType: String, CaseIterable, Codable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }
}

struct Meal: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var date: Date
    var type: MealType
    var notes: String
    var eaten = false
}
