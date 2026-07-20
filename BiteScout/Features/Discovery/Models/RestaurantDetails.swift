import Foundation

struct RestaurantDetails: Sendable {
    let about: String
    let overallRating: Double
    let categoryRatings: [(String, Double)]
    let noise: String
    let phone: String?
    let website: String?
    let pricing: String
    let operatingHours: [String]
    let serviceOptions: String
    let highlights: String
    let paymentOptions: String
    let parking: String
    let accessibility: String

    static func fixture(for restaurant: Restaurant) -> RestaurantDetails {
        if restaurant.name == "Ocean Basket Victoria Island" {
            return RestaurantDetails(
                about: "Welcome to Ocean Basket Victoria Island, where the moment comes alive with luxury, rhythm, and unforgettable experiences. Nestled in the heart of Lagos, we are a sanctuary for those who seek the best of seafood and Mediterranean hospitality.",
                overallRating: 4.7,
                categoryRatings: [("Food", 4.7), ("Service", 4.7), ("Ambience", 4.7)],
                noise: "Moderate",
                phone: "+234 708 338 2278",
                website: "oceanbasketlagos.com",
                pricing: "₦80,000 and over",
                operatingHours: ["Mon-Sat 9:00 AM - 11PM", "Sun 12:00AM - 11PM"],
                serviceOptions: "Dine-in, Takeaway",
                highlights: "Bar games, Great cocktails, Live music, Live performances",
                paymentOptions: "Card, Bank Transfers",
                parking: "Free of charge street parking, Valet parking, Free parking lot",
                accessibility: "Wheelchair-accessible entrance, seating and toilet"
            )
        }

        return RestaurantDetails(
            about: "Discover \(restaurant.name), a local dining destination in Lagos known for \(restaurant.cuisineSummary.lowercased()).",
            overallRating: restaurant.rating,
            categoryRatings: [("Food", restaurant.rating), ("Service", restaurant.rating), ("Ambience", restaurant.rating)],
            noise: "Moderate",
            phone: nil,
            website: nil,
            pricing: restaurant.formattedPriceLevel,
            operatingHours: ["Daily 9:00 AM - 11:00 PM"],
            serviceOptions: "Dine-in, Takeaway",
            highlights: "Great food and atmosphere",
            paymentOptions: "Card, Bank Transfers",
            parking: "Street parking",
            accessibility: "Contact the restaurant for accessibility information"
        )
    }
}

enum RestaurantDetailSection: String, CaseIterable, Identifiable, Sendable {
    case about = "About"
    case reviews = "Reviews"
    case menu = "Menu"
    case details = "Details"

    var id: Self { self }
}

enum RestaurantDetailRoute: String, Hashable {
    case photos
    case reviews
    case menu

    var title: String {
        switch self {
        case .photos: "Photos"
        case .reviews: "Reviews"
        case .menu: "Menu"
        }
    }

    var symbol: String {
        switch self {
        case .photos: "photo.on.rectangle.angled"
        case .reviews: "star.bubble"
        case .menu: "menucard"
        }
    }
}
