# Overview

Meal Planner is a small iOS app for planning meals and tracking what was eaten. Pick a date to see that day's breakfast, lunch, dinner, and snacks. Tap the plus button to add a meal, choose its type and date, and enter optional notes. Tap a meal's name to edit it. Tap its circle to mark it as eaten or planned. Swipe left to delete a meal and confirm the deletion.

My purpose for this project is to learn how SwiftUI forms, lists, and app state work together. I also want to understand how to save user-entered data on an iPhone. Meal entries are stored locally and loaded when the app starts again. This completes the local-storage stretch challenge. The daily list and add/edit sheet also provide two views for the user.

Software Demo Video: Pending recording and upload.

# Development Environment

The app was built on macOS using Xcode 26.6, Swift, and SwiftUI. It targets iOS 17 or later and uses Foundation for dates and JSON files and Observation to update the interface when meals change. No external packages, account, or server are needed.

Open `MealPlanner.xcodeproj` in Xcode, choose the **MealPlanner** scheme and an installed iPhone simulator, then click Run. The simulator does not require a paid developer account. To install on a physical iPhone, select your development team under Signing & Capabilities and choose your connected device.

Each meal stores an ID, name, date, meal type, notes, and whether it was eaten. `MealStore` saves the list as JSON in the app's Application Support directory at `MealPlanner/meals.json`. Completed changes save automatically. A failed write shows an error and leaves the existing list unchanged. If a saved file cannot be read, it is kept and saving is disabled to avoid overwriting it. To recover, restore that file from a backup and relaunch; removing the app and reinstalling also starts fresh but deletes its saved meals.

The date picker filters meals by calendar day. Saving a meal for another date takes the list to that date. Today returns to the current day. Entries are grouped by meal type. The eaten count reflects meals for the selected day. No meals are preloaded. Deleting an entry is permanent, and uninstalling the app removes its local data. Nutrition lookup, calorie calculations, and cloud sync are outside this version's scope.

To run the automated interface check in Xcode, choose **Product > Test**. `Tests/MealPlannerUITests.swift` checks adding, toggling eaten status, relaunching, editing notes, and deletion. `Tests/StoreChecks.swift` contains separate checks for validation, date filtering, JSON persistence, and file errors; it is not part of the app target. On a Mac, run:

```sh
swiftc MealPlanner/Meal.swift MealPlanner/MealStore.swift Tests/StoreChecks.swift -o /tmp/meal-store-checks
/tmp/meal-store-checks
```

# Useful Websites

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Observation Documentation](https://developer.apple.com/documentation/observation)
- [JSONEncoder Documentation](https://developer.apple.com/documentation/foundation/jsonencoder)
- [DatePicker Documentation](https://developer.apple.com/documentation/swiftui/datepicker)

# Future Work

- Copy meals from one date to another.
- Add a weekly planning view.
- Add export and backup options for saved meals.
