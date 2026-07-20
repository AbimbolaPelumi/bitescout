import SwiftUI

struct RestaurantListCard: View {
    let restaurant: Restaurant
    var onSelect: () -> Void = {}
    let onBookmark: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .aspectRatio(370 / 229, contentMode: .fit)
                    .overlay { RestaurantImage(name: restaurant.imageName) }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onSelect)

                bookmarkButton
                    .padding(14)
                    .accessibilityIdentifier("restaurant-bookmark")
                    .accessibilityLabel(restaurant.isBookmarked ? "Remove bookmark" : "Bookmark")
                    .accessibilityValue(restaurant.isBookmarked ? "Bookmarked" : "Not bookmarked")
                    .id(restaurant.isBookmarked)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(BiteScoutFont.sans(18, weight: .bold, relativeTo: .headline))
                    .lineLimit(1)
                    .truncationMode(.tail)

                VStack(alignment: .leading, spacing: 2) {
                    RestaurantMetadata(restaurant: restaurant, compact: true)
                    RestaurantAddress(text: restaurant.fullAddress, compact: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(restaurant.name)
        .accessibilityAction(named: "Open details", onSelect)
        .accessibilityIdentifier("restaurant-card-\(restaurant.id.uuidString)")
    }

    @ViewBuilder
    private var bookmarkButton: some View {
        Button {
            onBookmark()
            BiteScoutHaptics.shared.play(.mediumImpact)
        } label: {
            Image(systemName: "bookmark")
                .symbolVariant(restaurant.isBookmarked ? .fill : .none)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    restaurant.isBookmarked ? Color.accentColor : Color.black.opacity(0.28),
                    in: Circle()
                )
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Restaurant Card") {
    RestaurantListCard(restaurant: MockRestaurants.all[0], onBookmark: {})
        .padding()
}
