import SwiftUI

@main
struct MealPlannerApp: App {
    @State private var store = MealStore()

    var body: some Scene {
        WindowGroup {
            MealListView(store: store)
                .tint(.green)
        }
    }
}
