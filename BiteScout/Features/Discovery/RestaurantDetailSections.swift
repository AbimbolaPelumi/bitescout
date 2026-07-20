import MapKit
import SwiftUI

struct RestaurantAboutSection: View {
    let details: RestaurantDetails
    @Binding var isExpanded: Bool

    var body: some View {
        DetailSectionContainer(title: "About") {
            Text(details.about)
                .font(BiteScoutFont.sans(16, relativeTo: .body))
                .lineLimit(isExpanded ? nil : 4)
            Button(isExpanded ? "Read less" : "Read more") {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            }
            .buttonStyle(.plain)
            .font(BiteScoutFont.sans(16, weight: .semibold, relativeTo: .body))
            .foregroundStyle(.tint)
        }
    }
}

struct RestaurantReviewsSection: View {
    let restaurant: Restaurant
    let details: RestaurantDetails

    var body: some View {
        DetailSectionContainer(title: "Reviews") {
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Overall rating")
                        .font(BiteScoutFont.sans(15, weight: .semibold, relativeTo: .subheadline))
                        .foregroundStyle(.secondary)
                    Text(details.overallRating.formatted(.number.precision(.fractionLength(1))))
                        .font(BiteScoutFont.sans(44, weight: .bold, relativeTo: .largeTitle))
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                        }
                        Text(restaurant.formattedReviewCount)
                            .foregroundStyle(.secondary)
                    }
                    .font(BiteScoutFont.sans(12, relativeTo: .caption))
                    .foregroundStyle(.tint)
                }
                RatingBars()
            }

            HStack(alignment: .top) {
                ForEach(details.categoryRatings, id: \.0) { rating in
                    RatingMetric(title: rating.0, value: rating.1.formatted(.number.precision(.fractionLength(1))))
                }
                RatingMetric(title: "Noise", value: details.noise)
            }

            DetailNavigationButton(title: "View reviews", route: .reviews)
        }
    }
}

struct RestaurantMenuSection: View {
    let restaurant: Restaurant

    var body: some View {
        DetailSectionContainer(title: "Menu") {
            Text("Explore the menu offerings at \(restaurant.name) and discover the most popular dishes that people are craving!")
                .font(BiteScoutFont.sans(16, relativeTo: .body))
            DetailNavigationButton(title: "View full menu", route: .menu)
        }
    }
}

struct RestaurantInformationSection: View {
    let restaurant: Restaurant
    let details: RestaurantDetails

    var body: some View {
        DetailSectionContainer(title: "Details", showsDivider: false) {
            DetailRow(symbol: "mappin.and.ellipse", title: "Location") {
                VStack(alignment: .leading, spacing: 10) {
                    Map(initialPosition: .region(mapRegion)) {
                        Marker(restaurant.name, coordinate: restaurant.coordinate)
                            .tint(Color.accentColor)
                    }
                    .mapStyle(.standard(pointsOfInterest: .excludingAll))
                    .frame(height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .allowsHitTesting(false)

                    Text(restaurant.fullAddress)
                    if let directionsURL {
                        Link("Get directions", destination: directionsURL)
                            .foregroundStyle(.tint)
                    }
                }
            }

            if let phone = details.phone, let url = URL(string: "tel:\(phone.phoneURLValue)") {
                DetailRow(symbol: "phone", title: "Phone") {
                    Link(phone, destination: url).foregroundStyle(.tint)
                }
            }

            if let website = details.website, let url = URL(string: "https://\(website)") {
                DetailRow(symbol: "globe", title: "Website") {
                    Link(website, destination: url).foregroundStyle(.tint)
                }
            }

            DetailRow(symbol: "banknote", title: "Pricing", value: details.pricing)
            DetailRow(symbol: "fork.knife", title: "Cuisine", value: restaurant.cuisineSummary)
            DetailRow(symbol: "clock", title: "Operating hours", value: details.operatingHours.joined(separator: "\n"))
            DetailRow(symbol: "bag", title: "Service options", value: details.serviceOptions)
            DetailRow(symbol: "star", title: "Highlights", value: details.highlights)
            DetailRow(symbol: "creditcard", title: "Payment options", value: details.paymentOptions)
            DetailRow(symbol: "parkingsign.square", title: "Parking", value: details.parking)
            DetailRow(symbol: "accessibility", title: "Accessibility", value: details.accessibility)
        }
    }

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: restaurant.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        )
    }

    private var directionsURL: URL? {
        URL(string: "https://maps.apple.com/?daddr=\(restaurant.coordinate.latitude),\(restaurant.coordinate.longitude)")
    }
}

private struct DetailSectionContainer<Content: View>: View {
    let title: String
    var showsDivider = true
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(BiteScoutFont.sans(20, weight: .bold, relativeTo: .title3))
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .overlay(alignment: .bottom) {
            if showsDivider { Divider() }
        }
    }
}

private struct DetailRow<Content: View>: View {
    let symbol: String
    let title: String
    @ViewBuilder let content: Content

    init(symbol: String, title: String, @ViewBuilder content: () -> Content) {
        self.symbol = symbol
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .frame(width: 20)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(BiteScoutFont.sans(16, weight: .semibold, relativeTo: .headline))
                    .foregroundStyle(.secondary)
                content
                    .font(BiteScoutFont.sans(16, relativeTo: .body))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension DetailRow where Content == Text {
    init(symbol: String, title: String, value: String) {
        self.init(symbol: symbol, title: title) { Text(value) }
    }
}

private struct DetailNavigationButton: View {
    let title: String
    let route: RestaurantDetailRoute

    var body: some View {
        NavigationLink(value: route) {
            Text(title)
                .font(BiteScoutFont.sans(16, weight: .bold, relativeTo: .body))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay { Capsule().stroke(Color(.separator)) }
        }
        .buttonStyle(.plain)
    }
}

private struct RatingMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(.secondary)
            Text(value).fontWeight(.semibold)
        }
        .font(BiteScoutFont.sans(14, relativeTo: .subheadline))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RatingBars: View {
    private let values: [CGFloat] = [0.88, 0.14, 0.06, 0.02, 0.01]

    var body: some View {
        VStack(spacing: 7) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                HStack(spacing: 6) {
                    Text("\(5 - index)")
                        .font(BiteScoutFont.sans(11, relativeTo: .caption2))
                        .foregroundStyle(.secondary)
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.secondarySystemFill))
                            Capsule().fill(Color.accentColor).frame(width: proxy.size.width * value)
                        }
                    }
                    .frame(height: 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private extension String {
    var phoneURLValue: String {
        filter { $0.isNumber || $0 == "+" }
    }
}
