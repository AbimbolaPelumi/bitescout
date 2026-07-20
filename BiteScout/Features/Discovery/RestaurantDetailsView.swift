import SwiftUI

struct RestaurantDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var state: DiscoveryState
    let restaurantID: Restaurant.ID

    @State private var selectedSection: RestaurantDetailSection = .about
    @State private var isToolbarCollapsed = false
    @State private var isAboutExpanded = false
    @State private var sectionPositions: [RestaurantDetailSection: CGFloat] = [:]
    @State private var programmaticSelection: RestaurantDetailSection?
    @State private var selectionRevision = UUID()

    private var restaurant: Restaurant? {
        state.restaurants.first { $0.id == restaurantID }
    }

    var body: some View {
        NavigationStack {
            if let restaurant {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            RestaurantDetailHero(restaurant: restaurant)
                            RestaurantDetailSummary(restaurant: restaurant)

                            RestaurantDetailTabs(selection: selectedSection) { section in
                                select(section, using: proxy)
                            }
                            .opacity(isToolbarCollapsed ? 0 : 1)
                            .allowsHitTesting(!isToolbarCollapsed)
                            .accessibilityHidden(isToolbarCollapsed)
                            .background {
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: RestaurantDetailTabPositionKey.self,
                                        value: geometry.frame(in: .named("restaurant-details-scroll")).minY
                                    )
                                }
                            }

                            detailSections(for: restaurant)
                        }
                    }
                    .coordinateSpace(name: "restaurant-details-scroll")
                    .ignoresSafeArea(edges: .top)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        if isToolbarCollapsed {
                            RestaurantDetailTabs(selection: selectedSection) { section in
                                select(section, using: proxy)
                            }
                        }
                    }
                    .onPreferenceChange(RestaurantDetailTabPositionKey.self) { tabMinY in
                        // Hysteresis prevents the safe-area inset from repeatedly
                        // toggling as the inline strip reaches the navigation bar.
                        let shouldCollapse = isToolbarCollapsed ? tabMinY < 120 : tabMinY <= 60
                        guard shouldCollapse != isToolbarCollapsed else { return }
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) {
                            isToolbarCollapsed = shouldCollapse
                        }
                    }
                    .onPreferenceChange(RestaurantDetailSectionPositionsKey.self) { positions in
                        sectionPositions = positions
                        updateSelectedSection(from: positions)
                    }
                }
                .background(Color(.systemBackground))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(isToolbarCollapsed ? .visible : .hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: close) { Image(systemName: "xmark") }
                            .accessibilityLabel("Close restaurant details")
                    }
                    ToolbarItem(placement: .principal) {
                        Text(restaurant.name)
                            .font(BiteScoutFont.sans(17, weight: .semibold, relativeTo: .headline))
                            .lineLimit(1)
                            .opacity(isToolbarCollapsed ? 1 : 0)
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            state.toggleBookmark(restaurant.id)
                            BiteScoutHaptics.shared.play(.mediumImpact)
                        }) {
                            Image(systemName: "bookmark")
                                .symbolVariant(restaurant.isBookmarked ? .fill : .none)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .accessibilityLabel(restaurant.isBookmarked ? "Remove bookmark" : "Bookmark")
                        .accessibilityValue(restaurant.isBookmarked ? "Bookmarked" : "Not bookmarked")
                        .accessibilityIdentifier("restaurant-details-bookmark")

                        ShareLink(item: shareText(for: restaurant)) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share restaurant")
                    }
                }
                .navigationDestination(for: RestaurantDetailRoute.self) { route in
                    ContentUnavailableView(
                        route.title,
                        systemImage: route.symbol,
                        description: Text("This section is coming soon.")
                    )
                    .navigationTitle(route.title)
                }
            } else {
                ContentUnavailableView("Restaurant unavailable", systemImage: "fork.knife")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close", action: close)
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func detailSections(for restaurant: Restaurant) -> some View {
        let details = RestaurantDetails.fixture(for: restaurant)

        RestaurantAboutSection(details: details, isExpanded: $isAboutExpanded)
            .id(RestaurantDetailSection.about)
            .trackDetailSection(.about)

        RestaurantReviewsSection(restaurant: restaurant, details: details)
            .id(RestaurantDetailSection.reviews)
            .trackDetailSection(.reviews)

        RestaurantMenuSection(restaurant: restaurant)
            .id(RestaurantDetailSection.menu)
            .trackDetailSection(.menu)

        RestaurantInformationSection(restaurant: restaurant, details: details)
            .id(RestaurantDetailSection.details)
            .trackDetailSection(.details)
    }

    private func shareText(for restaurant: Restaurant) -> String {
        "Check out \(restaurant.name) at \(restaurant.fullAddress)"
    }

    private func select(_ section: RestaurantDetailSection, using proxy: ScrollViewProxy) {
        selectedSection = section
        programmaticSelection = section
        selectionRevision = UUID()
        let revision = selectionRevision
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            proxy.scrollTo(section, anchor: .top)
        }
        BiteScoutHaptics.shared.play(.selection)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 80 : 380))
            guard selectionRevision == revision else { return }
            programmaticSelection = nil
            updateSelectedSection(from: sectionPositions)
        }
    }

    private func updateSelectedSection(from positions: [RestaurantDetailSection: CGFloat]) {
        guard programmaticSelection == nil, !positions.isEmpty else { return }
        let activationLine: CGFloat = isToolbarCollapsed ? 116 : 16
        let passed = positions
            .filter { $0.value <= activationLine }
            .max { $0.value < $1.value }
        let next = positions.min { $0.value < $1.value }
        let newSelection = passed?.key ?? next?.key
        if let newSelection, selectedSection != newSelection {
            selectedSection = newSelection
        }
    }

    private func close() {
        state.presentedRestaurantID = nil
        dismiss()
    }
}

private struct RestaurantDetailTabPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

private struct RestaurantDetailSectionPositionsKey: PreferenceKey {
    static var defaultValue: [RestaurantDetailSection: CGFloat] = [:]

    static func reduce(
        value: inout [RestaurantDetailSection: CGFloat],
        nextValue: () -> [RestaurantDetailSection: CGFloat]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, newest in newest })
    }
}

private extension View {
    func trackDetailSection(_ section: RestaurantDetailSection) -> some View {
        background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: RestaurantDetailSectionPositionsKey.self,
                    value: [section: geometry.frame(in: .named("restaurant-details-scroll")).minY]
                )
            }
        }
    }
}

private struct RestaurantDetailHero: View {
    let restaurant: Restaurant

    var body: some View {
        RestaurantImage(name: restaurant.imageName)
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                NavigationLink(value: RestaurantDetailRoute.photos) {
                    Text("View all (30)")
                        .font(BiteScoutFont.sans(13, weight: .medium, relativeTo: .footnote))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(Color.black.opacity(0.42), in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(20)
            }
            .accessibilityLabel("Photo of \(restaurant.name)")
    }
}

private struct RestaurantDetailSummary: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(restaurant.name)
                .font(BiteScoutFont.sans(28, weight: .bold, relativeTo: .title))
                .fixedSize(horizontal: false, vertical: true)
            RestaurantMetadata(restaurant: restaurant)
            RestaurantAddress(text: restaurant.fullAddress)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

private struct RestaurantDetailTabs: View {
    let selection: RestaurantDetailSection
    let onSelect: (RestaurantDetailSection) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(RestaurantDetailSection.allCases) { section in
                Button(action: { onSelect(section) }) {
                    Text(section.rawValue)
                        .font(BiteScoutFont.sans(16, weight: selection == section ? .semibold : .regular, relativeTo: .body))
                        .foregroundStyle(selection == section ? Color.accentColor : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(selection == section ? Color.accentColor : Color.clear)
                                .frame(height: 2)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }
}
