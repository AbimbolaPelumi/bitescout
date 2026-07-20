import XCTest

final class BiteScoutUITests: XCTestCase {
    @MainActor
    func testBrandedSearchEditorAndNaturalLanguageResults() {
        continueAfterFailure = false
        let app = launchApp()

        XCTAssertTrue(app.tabBars.buttons["Search"].isSelected)
        XCTAssertTrue(app.buttons["branded-search-field"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.searchFields["Restaurants and cuisines"].exists)

        app.buttons["branded-search-field"].tap()
        let query = app.textFields["query-field"]
        XCTAssertTrue(query.waitForExistence(timeout: 2))
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)
        query.typeText("Seafood on Friday night")

        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Ocean Basket")).firstMatch.waitForExistence(timeout: 2))
        app.buttons["submit-search"].tap()

        XCTAssertTrue(app.staticTexts["1 location"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Ocean Basket Victoria Island"].exists)
        XCTAssertFalse(app.staticTexts["Nok by Alara"].exists)
    }

    @MainActor
    func testFilterDraftApplyClearAndBookmark() {
        continueAfterFailure = false
        let app = launchApp()

        let bookmark = app.buttons["restaurant-bookmark"].firstMatch
        XCTAssertTrue(bookmark.waitForExistence(timeout: 2))
        bookmark.tap()
        XCTAssertTrue(app.buttons["Remove bookmark"].waitForExistence(timeout: 2))

        app.buttons["restaurant-filter-button"].tap()
        XCTAssertTrue(app.staticTexts["Filters"].waitForExistence(timeout: 2))
        app.buttons["filter-type-Fine dining"].tap()
        app.buttons["Apply filters"].tap()

        XCTAssertTrue(app.buttons["restaurant-filter-button"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Clear filters"].exists)

        app.buttons["Clear filters"].tap()
        XCTAssertTrue(app.staticTexts["20 locations"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSuggestionDismissesEditorAndOpensDetails() {
        continueAfterFailure = false
        let app = launchApp()
        app.buttons["branded-search-field"].tap()

        let query = app.textFields["query-field"]
        XCTAssertTrue(query.waitForExistence(timeout: 2))
        query.typeText("Ocean")
        let suggestion = app.buttons["restaurant-suggestion"].firstMatch
        XCTAssertTrue(suggestion.waitForExistence(timeout: 2))
        suggestion.tap()

        XCTAssertTrue(app.buttons["Close restaurant details"].waitForExistence(timeout: 4))
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)
    }

    @MainActor
    func testMapUsesNativeNavigationAndKeepsTabsAvailable() {
        continueAfterFailure = false
        let app = launchApp()
        app.buttons["search-map-button"].tap()

        XCTAssertTrue(app.navigationBars["Map"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.tabBars.firstMatch.exists)

        app.navigationBars["Map"].buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["branded-search-field"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testRestaurantDetailsHideTabsAndExposeSectionNavigation() {
        continueAfterFailure = false
        let app = launchApp()
        app.staticTexts["Ocean Basket Victoria Island"].firstMatch.tap()

        XCTAssertTrue(app.buttons["Close restaurant details"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.tabBars.firstMatch.isHittable)

        let detailsBookmark = app.buttons["restaurant-details-bookmark"]
        XCTAssertTrue(detailsBookmark.waitForExistence(timeout: 2))
        detailsBookmark.tap()
        XCTAssertEqual(detailsBookmark.value as? String, "Bookmarked")

        for title in ["About", "Reviews", "Menu", "Details"] {
            XCTAssertTrue(app.buttons[title].exists)
        }

        app.buttons["Details"].tap()
        XCTAssertTrue(app.staticTexts["Operating hours"].waitForExistence(timeout: 3))
        let detailsTabs = app.buttons.matching(NSPredicate(format: "label == %@", "Details"))
        XCTAssertTrue(detailsTabs.allElementsBoundByIndex.contains { $0.isHittable })
        app.buttons["Close restaurant details"].tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Remove bookmark"].waitForExistence(timeout: 2))
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }
}
