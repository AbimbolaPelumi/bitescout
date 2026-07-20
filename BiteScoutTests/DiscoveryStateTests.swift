import CoreLocation
import Testing
@testable import BiteScout

@Suite("Discovery state")
struct DiscoveryStateTests {
    @Test("Search is case and diacritic insensitive")
    func normalizedSearch() {
        var state = DiscoveryState(restaurants: fixtures)

        state.submitSearch("OCEAN")
        #expect(state.visibleRestaurants.map(\.name) == ["Ocean Basket"])

        state.submitSearch("cafe")
        #expect(state.visibleRestaurants.map(\.name) == ["Café Neo"])
    }

    @Test("Natural phrases retain meaningful search tokens")
    func tokenizedSearch() {
        var state = DiscoveryState(restaurants: fixtures)
        state.submitSearch("Seafood on Friday night")

        #expect(state.visibleRestaurants.map(\.name) == ["Ocean Basket"])
        #expect("Seafood on Friday night".searchTokens == ["seafood"])
    }

    @Test("Empty editor shows no suggestions and entered text shows matches")
    func suggestions() {
        let state = DiscoveryState(restaurants: fixtures)

        #expect(state.suggestions(for: "").isEmpty)
        #expect(state.suggestions(for: "mediterranean").map(\.name) == ["Ocean Basket"])
    }

    @Test("Selecting a suggestion prepares its result and detail presentation")
    func suggestionSelection() {
        var state = DiscoveryState(restaurants: fixtures)

        state.focusResult(fixtures[0].id)

        #expect(state.searchText == "Ocean Basket")
        #expect(state.presentation == .results)
        #expect(state.suggestionSelectionID == fixtures[0].id)
        #expect(state.presentedRestaurantID == nil)
    }

    @Test("Quick filters narrow and reset results")
    func quickFilters() {
        var state = DiscoveryState(restaurants: fixtures)

        state.selectFilter(.cafe)
        #expect(state.visibleRestaurants.map(\.name) == ["Café Neo"])

        state.selectFilter(nil)
        #expect(state.visibleRestaurants.count == fixtures.count)
    }

    @Test("Lists quick filter shows bookmarked restaurants without changing tabs")
    func listsQuickFilter() {
        var state = DiscoveryState(restaurants: fixtures)
        state.toggleBookmark(fixtures[0].id)

        state.selectFilter(.lists)

        #expect(state.visibleRestaurants.map(\.name) == ["Ocean Basket"])
        #expect(state.activeFilter == .lists)
    }

    @Test("Committed filters combine dimensions and badge excludes sort")
    func committedFilters() {
        var state = DiscoveryState(restaurants: fixtures)
        let filters = SearchFilters(
            ratings: [4],
            restaurantTypes: [.cafe],
            priceLevels: [1],
            cuisines: ["Bakery"]
        )

        state.applyFilters(filters)

        #expect(state.visibleRestaurants.map(\.name) == ["Café Neo"])
        #expect(state.appliedFilters.activeCount == 4)

        var sortOnly = SearchFilters()
        sortOnly.sort = .topRated
        #expect(sortOnly.activeCount == 0)
        #expect(!sortOnly.isEmpty)
    }

    @Test("Clear restores default filters")
    func clearFilters() {
        var state = DiscoveryState(restaurants: fixtures)
        state.applyFilters(SearchFilters(priceLevels: [4]))
        #expect(state.visibleRestaurants.isEmpty)

        state.clearFilters()
        #expect(state.visibleRestaurants.count == fixtures.count)
        #expect(state.appliedFilters == SearchFilters())
    }

    @Test("Sort modes order by rating and distance")
    func sorting() {
        var state = DiscoveryState(restaurants: fixtures)
        state.applyFilters(SearchFilters(sort: .topRated))
        #expect(state.visibleRestaurants.map(\.name) == ["Café Neo", "Ocean Basket"])

        state.applyFilters(SearchFilters(sort: .closest))
        #expect(state.visibleRestaurants.first?.name == "Ocean Basket")
    }

    @Test("Bookmark mutation persists in state")
    func bookmarkMutation() {
        var state = DiscoveryState(restaurants: fixtures)
        let restaurantID = fixtures[0].id

        state.toggleBookmark(restaurantID)

        #expect(state.restaurants.first?.isBookmarked == true)
    }

    @Test("Selection normalizes when the current restaurant is filtered out")
    func selectionNormalization() {
        var state = DiscoveryState(restaurants: fixtures, selectedRestaurantID: fixtures[0].id)

        state.selectFilter(.cafe)

        #expect(state.selectedRestaurantID == fixtures[1].id)
    }

    private var fixtures: [Restaurant] {
        [
            Restaurant(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, pinNumber: 1,
                name: "Ocean Basket", rating: 4.0, reviewCount: 5_200, priceLevel: 2,
                cuisines: ["Seafood", "Mediterranean"], fullAddress: "Victoria Island, Lagos",
                shortAddress: "Lagos", imageName: "",
                coordinate: CLLocationCoordinate2D(latitude: 6.428, longitude: 3.421), isBookmarked: false
            ),
            Restaurant(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, pinNumber: 2,
                name: "Café Neo", rating: 4.8, reviewCount: 760, priceLevel: 1,
                cuisines: ["Café", "Bakery"], fullAddress: "Victoria Island, Lagos",
                shortAddress: "Lagos", imageName: "",
                coordinate: CLLocationCoordinate2D(latitude: 6.439, longitude: 3.437), isBookmarked: false
            )
        ]
    }
}
