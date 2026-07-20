import SwiftUI

struct RestaurantMetadata: View {
    let restaurant: Restaurant
    var compact = false

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 5) { metaContent }
            VStack(alignment: .leading, spacing: 2) { metaContent }
        }
        .font(compact
              ? BiteScoutFont.sans(13, relativeTo: .footnote)
              : BiteScoutFont.sans(15, relativeTo: .subheadline))
        .lineLimit(2)
    }

    @ViewBuilder private var metaContent: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text(restaurant.rating.formatted(.number.precision(.fractionLength(1))))
                .fontWeight(.semibold)
            Text("(\(restaurant.formattedReviewCount))").foregroundStyle(.secondary)
        }
        .foregroundStyle(.tint)
        Text("·  \(restaurant.formattedPriceLevel)  ·  \(restaurant.cuisineSummary)")
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
}

struct RestaurantAddress: View {
    let text: String
    var compact = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
            Text(text).lineLimit(1).truncationMode(.tail)
        }
        .font(compact
              ? BiteScoutFont.sans(13, relativeTo: .footnote)
              : BiteScoutFont.sans(14, relativeTo: .footnote))
        .foregroundStyle(.secondary)
    }
}
