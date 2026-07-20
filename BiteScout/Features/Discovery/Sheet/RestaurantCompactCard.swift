import SwiftUI

struct RestaurantCompactCard: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            RestaurantImage(name: restaurant.imageName)
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                Text(restaurant.name)
                    .font(BiteScoutFont.sans(17, weight: .bold, relativeTo: .headline))
                    .lineLimit(2)
                    .truncationMode(.tail)
                RestaurantMetadata(restaurant: restaurant, compact: true)
                RestaurantAddress(text: restaurant.shortAddress, compact: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(height: 112)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .accessibilityElement(children: .combine)
    }
}
