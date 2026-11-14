import Foundation
import Observation

@Observable
@MainActor
final class MealStore {
    private(set) var meals: [Meal] = []
    var errorMessage: String?
    private let fileURL: URL
    private var canSave = true

    init(fileURL: URL? = nil) {
        let folder = URL.applicationSupportDirectory.appending(path: "MealPlanner")
        self.fileURL = fileURL ?? folder.appending(path: "meals.json")
        load()
    }

    func meals(on date: Date, type: MealType? = nil) -> [Meal] {
        // Compare calendar days so the time of day does not affect the list.
        meals.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date) && (type == nil || $0.type == type)
        }
    }

    @discardableResult
    func saveMeal(_ meal: Meal) -> Bool {
        var cleaned = meal
        cleaned.name = meal.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.name.isEmpty else {
            errorMessage = "Enter a meal name before saving."
            return false
        }
        var updated = meals
        if let index = updated.firstIndex(where: { $0.id == cleaned.id }) {
            updated[index] = cleaned
        } else {
            updated.append(cleaned)
        }
        return persist(updated)
    }

    func toggleEaten(_ meal: Meal) {
        var updated = meals
        guard let index = updated.firstIndex(where: { $0.id == meal.id }) else { return }
        updated[index].eaten.toggle()
        persist(updated)
    }

    func delete(_ meal: Meal) {
        persist(meals.filter { $0.id != meal.id })
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            meals = try JSONDecoder().decode([Meal].self, from: data)
        } catch {
            // Keep an unreadable file instead of replacing it with an empty list.
            canSave = false
            errorMessage = "Saved meals could not be opened. Your file has been kept. Restart the app after restoring the meals.json file from a backup."
        }
    }

    @discardableResult
    private func persist(_ updated: [Meal]) -> Bool {
        guard canSave else {
            errorMessage = "Saving is unavailable because the saved meal file could not be read. Your existing file has been kept."
            return false
        }
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(updated)
            // Write the whole file safely before changing the list on screen.
            try data.write(to: fileURL, options: .atomic)
            meals = updated
            return true
        } catch {
            errorMessage = "Your change could not be saved. Check the device's available storage and try again."
            return false
        }
    }
}
