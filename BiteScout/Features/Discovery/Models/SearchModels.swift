import Foundation

enum SearchPresentation: Equatable, Sendable {
    case landing
    case results
}

enum SearchSort: String, CaseIterable, Identifiable, Sendable {
    case relevance = "Relevance"
    case closest = "Closest"
    case topRated = "Top rated"

    var id: Self { self }
}

struct SearchFilters: Equatable, Sendable {
    var sort: SearchSort = .relevance
    var ratings: Set<Int> = []
    var includesUnrated = false
    var restaurantTypes: Set<RestaurantFilter> = []
    var priceLevels: Set<Int> = []
    var cuisines: Set<String> = []

    var activeCount: Int {
        ratings.count + (includesUnrated ? 1 : 0)
            + restaurantTypes.count + priceLevels.count + cuisines.count
    }

    var isEmpty: Bool {
        activeCount == 0 && sort == .relevance
    }

    mutating func clear() {
        self = SearchFilters()
    }
}
