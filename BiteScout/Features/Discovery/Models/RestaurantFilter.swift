import Foundation

enum RestaurantFilter: String, CaseIterable, Hashable, Identifiable, Sendable {
    case lists = "Lists"
    case fineDining = "Fine dining"
    case family = "Family"
    case cafe = "Café"
    case buffet = "Buffet"
    case fastFood = "Fast food"
    case pizza = "Pizza"
    case bar = "Bar"
    case bakery = "Bakery"
    case diner = "Diner"
    case casual = "Casual"

    var id: Self { self }
    var title: String { rawValue }

    static let quickFilters: [RestaurantFilter] = [
        .lists, .fineDining, .family, .cafe, .buffet, .fastFood, .pizza, .bar, .bakery
    ]

    static let sheetFilters: [RestaurantFilter] = [
        .fineDining, .family, .cafe, .buffet, .diner, .casual
    ]
}
