import SwiftUI

struct RestaurantCarousel: View {
    let restaurants: [Restaurant]
    @Binding var selectedRestaurantID: Restaurant.ID?

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(restaurants) { restaurant in
                        Button(action: {
                            guard selectedRestaurantID != restaurant.id else { return }
                            BiteScoutHaptics.shared.play(.selection)
                            selectedRestaurantID = restaurant.id
                        }) {
                            RestaurantCompactCard(restaurant: restaurant)
                        }
                        .buttonStyle(.plain)
                        .frame(width: cardWidth(for: proxy.size.width))
                        .id(restaurant.id)
                        .accessibilityLabel("Select \(restaurant.name)")
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $selectedRestaurantID)
            .scrollIndicators(.hidden)
        }
        .frame(height: 128)
        .accessibilityLabel("Restaurant carousel")
    }

    private func cardWidth(for availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth - 32, 280), 420)
    }
}
