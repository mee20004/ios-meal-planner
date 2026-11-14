import Foundation

@main
struct StoreChecks {
    @MainActor
    static func main() throws {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appending(path: "meals.json")
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let store = MealStore(fileURL: file)
        assert(store.meals.isEmpty)
        var meal = Meal(name: "  Oatmeal  ", date: today, type: .breakfast, notes: "Fruit")
        assert(store.saveMeal(meal))
        assert(store.meals.first?.name == "Oatmeal")
        assert(store.meals(on: today).count == 1)
        assert(store.meals(on: tomorrow).isEmpty)
        assert(store.meals(on: today, type: .dinner).isEmpty)
        store.toggleEaten(meal)
        let reloaded = MealStore(fileURL: file)
        assert(reloaded.meals.first?.eaten == true)
        meal.name = "Toast"
        meal.date = tomorrow
        meal.type = .lunch
        meal.eaten = true
        assert(reloaded.saveMeal(meal))
        assert(reloaded.meals(on: today).isEmpty)
        assert(reloaded.meals(on: tomorrow, type: .lunch).first?.name == "Toast")
        let blank = Meal(name: " \n ", date: today, type: .snack, notes: "")
        assert(!reloaded.saveMeal(blank))
        assert(reloaded.meals.count == 1)
        reloaded.delete(meal)
        assert(MealStore(fileURL: file).meals.isEmpty)
        try Data("broken".utf8).write(to: file)
        let broken = MealStore(fileURL: file)
        assert(broken.errorMessage != nil)
        assert(!broken.saveMeal(meal))
        let contents = try String(contentsOf: file, encoding: .utf8)
        assert(contents == "broken")
        let blocker = folder.appending(path: "not-a-folder")
        try Data().write(to: blocker)
        let failing = MealStore(fileURL: blocker.appending(path: "meals.json"))
        assert(!failing.saveMeal(meal))
        assert(failing.meals.isEmpty)
        print("PASS: create, trim, validate, date/type filtering, edit, toggle, save/reload, delete, unreadable file protection, and failed-write handling.")
    }
}
