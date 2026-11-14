import SwiftUI

struct MealListView: View {
    @Bindable var store: MealStore
    @State private var selectedDate = Date()
    @State private var editor: Meal?
    @State private var mealToDelete: Meal?

    private var dailyMeals: [Meal] { store.meals(on: selectedDate) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Meals for", selection: $selectedDate, displayedComponents: .date)
                        .accessibilityIdentifier("selectedDate")
                    Text("\(dailyMeals.filter(\.eaten).count) of \(dailyMeals.count) meals eaten")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("daySummary")
                }
                if dailyMeals.isEmpty {
                    ContentUnavailableView {
                        Label("Plan something good", systemImage: "fork.knife")
                    } description: {
                        Text("Add a meal for this day, then check it off when you've eaten.")
                    } actions: {
                        Button("Add a meal") { addMeal() }
                            .buttonStyle(.borderedProminent)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(MealType.allCases) { type in
                        let entries = store.meals(on: selectedDate, type: type)
                        if !entries.isEmpty {
                            Section(type.rawValue) {
                                ForEach(entries) { meal in
                                    mealRow(meal)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meal Planner")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Today") { selectedDate = Date() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add meal", systemImage: "plus") { addMeal() }
                        .accessibilityIdentifier("addMeal")
                }
            }
            .sheet(item: $editor) { meal in
                MealEditor(store: store, meal: meal) { date in
                    selectedDate = date
                }
            }
            .alert("Delete meal?", isPresented: Binding(
                get: { mealToDelete != nil },
                set: { if !$0 { mealToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let meal = mealToDelete { store.delete(meal) }
                    mealToDelete = nil
                }
                Button("Cancel", role: .cancel) { mealToDelete = nil }
            } message: {
                Text("This removes the meal from your plan.")
            }
            .alert("Could not save meals", isPresented: Binding(
                get: { store.errorMessage != nil && editor == nil },
                set: { if !$0 { store.errorMessage = nil } }
            )) {
                Button("OK") { store.errorMessage = nil }
            } message: { Text(store.errorMessage ?? "") }
        }
    }

    private func addMeal() {
        editor = Meal(name: "", date: selectedDate, type: .breakfast, notes: "")
    }

    private func mealRow(_ meal: Meal) -> some View {
        HStack(spacing: 12) {
            Button {
                store.toggleEaten(meal)
            } label: {
                Image(systemName: meal.eaten ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(meal.eaten ? "Mark \(meal.name) as planned" : "Mark \(meal.name) as eaten")
            .accessibilityIdentifier("toggle-\(meal.name)")
            Button {
                editor = meal
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name).font(.headline).foregroundStyle(.primary)
                        .strikethrough(meal.eaten)
                    Text(meal.eaten ? "Eaten" : "Planned")
                        .font(.subheadline).foregroundStyle(.secondary)
                    if !meal.notes.isEmpty {
                        Text(meal.notes).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("edit-\(meal.name)")
        }
        .swipeActions {
            Button("Delete", role: .destructive) { mealToDelete = meal }
        }
    }
}
