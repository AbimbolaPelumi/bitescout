import CoreLocation
import Foundation

struct Restaurant: Identifiable, Hashable, Sendable {
    let id: UUID
    let pinNumber: Int
    let name: String
    let rating: Double
    let reviewCount: Int
    let priceLevel: Int
    let cuisines: [String]
    let fullAddress: String
    let shortAddress: String
    let imageName: String
    let coordinate: CLLocationCoordinate2D
    var isBookmarked: Bool

    /// Identity is still `id`, but value equality must include mutable UI state.
    /// Otherwise SwiftUI can legitimately treat a bookmark mutation as unchanged.
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id && lhs.isBookmarked == rhs.isBookmarked
    }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var formattedReviewCount: String {
        guard reviewCount >= 1_000 else { return reviewCount.formatted() }
        let count = Double(reviewCount) / 1_000
        let value = String(format: "%.1f", count).replacingOccurrences(of: ".0", with: "")
        return "\(value)K"
    }

    var formattedPriceLevel: String { String(repeating: "$", count: priceLevel) }
    var cuisineSummary: String { cuisines.joined(separator: " · ") }
}
