import CoreLocation
import Foundation

struct DiscoveryState: Sendable {
    static let lagosCenter = CLLocation(latitude: 6.4281, longitude: 3.4219)

    var restaurants: [Restaurant]
    var searchText: String
    var presentation: SearchPresentation
    var activeFilter: RestaurantFilter?
    var appliedFilters: SearchFilters
    var selectedRestaurantID: Restaurant.ID?
    var presentedRestaurantID: Restaurant.ID?
    var suggestionSelectionID: Restaurant.ID?
    var isSearchEditorPresented = false
    var isFilterSheetPresented = false

    init(
        restaurants: [Restaurant] = MockRestaurants.all,
        searchText: String = "",
        presentation: SearchPresentation = .landing,
        activeFilter: RestaurantFilter? = nil,
        appliedFilters: SearchFilters = SearchFilters(),
        selectedRestaurantID: Restaurant.ID? = nil,
        presentedRestaurantID: Restaurant.ID? = nil,
        suggestionSelectionID: Restaurant.ID? = nil
    ) {
        self.restaurants = restaurants
        self.searchText = searchText
        self.presentation = presentation
        self.activeFilter = activeFilter
        self.appliedFilters = appliedFilters
        self.selectedRestaurantID = selectedRestaurantID ?? restaurants.first?.id
        self.presentedRestaurantID = presentedRestaurantID
        self.suggestionSelectionID = suggestionSelectionID
        normalizeSelection()
    }

    var visibleRestaurants: [Restaurant] {
        let matching = restaurants.filter { restaurant in
            restaurant.matches(query: presentation == .results ? searchText : "")
                && restaurant.matches(quickFilter: activeFilter)
                && restaurant.matches(filters: appliedFilters)
        }

        switch appliedFilters.sort {
        case .relevance:
            return matching
        case .closest:
            return matching.sorted { $0.distanceFromLagosCenter < $1.distanceFromLagosCenter }
        case .topRated:
            return matching.sorted {
                $0.rating == $1.rating ? $0.reviewCount > $1.reviewCount : $0.rating > $1.rating
            }
        }
    }

    var selectedRestaurant: Restaurant? {
        guard let selectedRestaurantID else { return visibleRestaurants.first }
        return visibleRestaurants.first { $0.id == selectedRestaurantID }
    }

    var presentedRestaurant: Restaurant? {
        guard let presentedRestaurantID else { return nil }
        return restaurants.first { $0.id == presentedRestaurantID }
    }

    var resultTitle: String {
        presentation == .landing
            ? "Popular Restaurants in Lagos, NG"
            : "Search results for “\(searchText) in Lagos, NG”"
    }

    var filterSummary: String? {
        guard !appliedFilters.isEmpty else { return nil }
        var values: [String] = []
        if appliedFilters.sort != .relevance { values.append("Sort by \(appliedFilters.sort.rawValue)") }
        values.append(contentsOf: appliedFilters.restaurantTypes.map(\.title).sorted())
        values.append(contentsOf: appliedFilters.priceLevels.sorted().map { String(repeating: "$", count: $0) })
        values.append(contentsOf: appliedFilters.cuisines.sorted())
        values.append(contentsOf: appliedFilters.ratings.sorted(by: >).map { "\($0) stars" })
        if appliedFilters.includesUnrated { values.append("Unrated") }
        return values.joined(separator: ", ")
    }

    func suggestions(for query: String) -> [Restaurant] {
        guard !query.searchTokens.isEmpty else { return [] }
        return Array(restaurants.filter { $0.matches(query: query) }.prefix(10))
    }

    mutating func submitSearch(_ query: String) {
        searchText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        presentation = .results
        isSearchEditorPresented = false
        normalizeSelection()
    }

    mutating func focusResult(_ id: Restaurant.ID) {
        guard let restaurant = restaurants.first(where: { $0.id == id }) else { return }
        searchText = restaurant.name
        presentation = .results
        suggestionSelectionID = id
        selectedRestaurantID = id
        isSearchEditorPresented = false
    }

    mutating func selectFilter(_ filter: RestaurantFilter?) {
        activeFilter = filter
        normalizeSelection()
    }

    mutating func applyFilters(_ filters: SearchFilters) {
        appliedFilters = filters
        normalizeSelection()
    }

    mutating func clearFilters() {
        appliedFilters.clear()
        normalizeSelection()
    }

    mutating func selectRestaurant(_ id: Restaurant.ID) {
        guard visibleRestaurants.contains(where: { $0.id == id }) else { return }
        selectedRestaurantID = id
    }

    mutating func toggleBookmark(_ id: Restaurant.ID) {
        guard let index = restaurants.firstIndex(where: { $0.id == id }) else { return }
        restaurants[index].isBookmarked.toggle()
    }

    mutating func normalizeSelection() {
        guard !visibleRestaurants.isEmpty else {
            selectedRestaurantID = nil
            return
        }
        if !visibleRestaurants.contains(where: { $0.id == selectedRestaurantID }) {
            selectedRestaurantID = visibleRestaurants.first?.id
        }
    }
}

private extension Restaurant {
    var searchableText: String {
        ([name, fullAddress, shortAddress] + cuisines).joined(separator: " ").searchKey
    }

    var distanceFromLagosCenter: CLLocationDistance {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            .distance(from: DiscoveryState.lagosCenter)
    }

    func matches(query: String) -> Bool {
        let tokens = query.searchTokens
        guard !tokens.isEmpty else { return true }
        return tokens.allSatisfy(searchableText.contains)
    }

    func matches(quickFilter: RestaurantFilter?) -> Bool {
        guard let quickFilter else { return true }
        return matches(type: quickFilter)
    }

    func matches(filters: SearchFilters) -> Bool {
        let hasRatingFilter = !filters.ratings.isEmpty || filters.includesUnrated
        let ratingMatch = !hasRatingFilter
            || filters.ratings.contains(Int(rating.rounded(.down)))
            || (filters.includesUnrated && rating <= 0)
        let typeMatch = filters.restaurantTypes.isEmpty || filters.restaurantTypes.contains(where: matches(type:))
        let priceMatch = filters.priceLevels.isEmpty || filters.priceLevels.contains(priceLevel)
        let cuisineMatch = filters.cuisines.isEmpty
            || !Set(cuisines.map(\.searchKey)).isDisjoint(with: Set(filters.cuisines.map(\.searchKey)))
        return ratingMatch && typeMatch && priceMatch && cuisineMatch
    }

    func matches(type: RestaurantFilter) -> Bool {
        let keys = cuisines.map(\.searchKey)
        switch type {
        case .lists: return isBookmarked
        case .family: return keys.contains(where: { $0.contains("family") })
        case .cafe: return keys.contains(where: { $0.contains("cafe") })
        case .buffet: return keys.contains(where: { $0.contains("buffet") })
        default: return keys.contains(where: { $0.contains(type.title.searchKey) })
        }
    }
}

extension String {
    var searchKey: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var searchTokens: [String] {
        let ignored: Set<String> = [
            "a", "an", "and", "at", "for", "friday", "in", "lagos", "ng", "night", "on", "restaurant", "the", "with"
        ]
        return searchKey
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 && !ignored.contains($0) }
    }
}
