import XCTest

final class MealPlannerUITests: XCTestCase {
    func testAddTrackEditAndRelaunch() {
        let app = XCUIApplication()
        app.launch()
        let name = "UITest-\(UUID().uuidString.prefix(6))"
        app.buttons["addMeal"].tap()
        XCTAssertTrue(app.buttons["saveMeal"].exists)
        XCTAssertFalse(app.buttons["saveMeal"].isEnabled)
        app.textFields["mealName"].tap()
        app.textFields["mealName"].typeText(name)
        app.buttons["saveMeal"].tap()
        let toggle = app.buttons["toggle-\(name)"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()
        XCTAssertTrue(toggle.label.contains("as planned"))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["toggle-\(name)"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["toggle-\(name)"].label.contains("as planned"))
        app.buttons["edit-\(name)"].tap()
        app.textFields["mealNotes"].tap()
        app.textFields["mealNotes"].typeText("Saved note")
        app.buttons["saveMeal"].tap()
        XCTAssertTrue(app.staticTexts["Saved note"].waitForExistence(timeout: 5))
        app.buttons["edit-\(name)"].swipeLeft()
        app.buttons["Delete"].firstMatch.tap()
        app.alerts.buttons["Delete"].tap()
        XCTAssertFalse(app.buttons["edit-\(name)"].exists)
    }
}
