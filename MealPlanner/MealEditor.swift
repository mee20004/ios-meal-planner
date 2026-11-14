import SwiftUI

struct MealEditor: View {
    @Bindable var store: MealStore
    @State var meal: Meal
    var onSave: (Date) -> Void
    @Environment(\.dismiss) private var dismiss

    private var isNew: Bool { !store.meals.contains { $0.id == meal.id } }

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal details") {
                    TextField("Meal name", text: $meal.name)
                        .accessibilityIdentifier("mealName")
                    Picker("Meal type", selection: $meal.type) {
                        ForEach(MealType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    DatePicker("Date", selection: $meal.date, displayedComponents: .date)
                    TextField("Notes (optional)", text: $meal.notes, axis: .vertical)
                        .lineLimit(2...5)
                        .accessibilityIdentifier("mealNotes")
                }
                Section {
                    Toggle("Already eaten", isOn: $meal.eaten)
                }
            }
            .navigationTitle(isNew ? "Add meal" : "Edit meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Keep the form open if saving fails.
                        if store.saveMeal(meal) {
                            onSave(meal.date)
                            dismiss()
                        }
                    }
                    .disabled(meal.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("saveMeal")
                }
            }
            .alert("Could not save meal", isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.errorMessage = nil } }
            )) {
                Button("OK") { store.errorMessage = nil }
            } message: { Text(store.errorMessage ?? "") }
        }
    }
}
