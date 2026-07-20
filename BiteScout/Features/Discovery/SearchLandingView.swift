import SwiftUI

struct SearchLandingView: View {
    @Binding var state: DiscoveryState
    let onOpenSearch: () -> Void
    let onOpenFilters: () -> Void
    let onOpenRestaurant: (Restaurant.ID) -> Void

    private var restaurants: [Restaurant] { state.visibleRestaurants }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                resultSummary

                ForEach(restaurants) { restaurant in
                    RestaurantListCard(
                        restaurant: restaurant,
                        onSelect: { onOpenRestaurant(restaurant.id) },
                        onBookmark: { state.toggleBookmark(restaurant.id) }
                    )
                }
            }
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .top, spacing: 0) {
            SearchHeader(
                state: $state,
                onOpenSearch: onOpenSearch,
                onOpenFilters: onOpenFilters
            )
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !restaurants.isEmpty {
                NavigationLink(value: SearchRoute.map) {
                    Label("Map", systemImage: "map")
                        .font(BiteScoutFont.sans(14, weight: .bold, relativeTo: .body))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 40)
                        .background(Color.accentColor, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 8)
                .accessibilityIdentifier("search-map-button")
            }
        }
        .overlay {
            if restaurants.isEmpty {
                ContentUnavailableView(
                    "No restaurants found",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your search or filters.")
                )
            }
        }
    }

    private var resultSummary: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(state.resultTitle)
                .font(BiteScoutFont.sans(18, weight: .bold, relativeTo: .headline))
            Text("\(restaurants.count) location\(restaurants.count == 1 ? "" : "s")")
                .font(BiteScoutFont.sans(13, relativeTo: .footnote))
                .foregroundStyle(.secondary)

            if let filterSummary = state.filterSummary {
                Text("Showing results for \(filterSummary)")
                    .font(BiteScoutFont.sans(12, relativeTo: .caption))
                    .foregroundStyle(.secondary)
                Button("Clear filters") {
                    BiteScoutHaptics.shared.play(.lightImpact)
                    state.clearFilters()
                }
                    .font(BiteScoutFont.sans(12, weight: .semibold, relativeTo: .caption))
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SearchHeader: View {
    @Binding var state: DiscoveryState
    let onOpenSearch: () -> Void
    let onOpenFilters: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Button(action: onOpenSearch) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                        Text(state.searchText.isEmpty ? "Search" : state.searchText)
                            .lineLimit(1)
                            .foregroundStyle(state.searchText.isEmpty ? .secondary : .primary)
                        Spacer(minLength: 8)
                        Text("Lagos, NG")
                            .font(BiteScoutFont.sans(14, relativeTo: .subheadline))
                            .foregroundStyle(.secondary)
                    }
                    .font(BiteScoutFont.sans(16, relativeTo: .body))
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.biteScoutControlSurface, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("branded-search-field")

                Button(action: onOpenFilters) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(Color.biteScoutControlSurface, in: Circle())
                        .overlay(alignment: .topTrailing) {
                            if state.appliedFilters.activeCount > 0 {
                                Text("\(state.appliedFilters.activeCount)")
                                    .font(BiteScoutFont.sans(11, weight: .bold, relativeTo: .caption2))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 18, minHeight: 18)
                                    .background(Color.accentColor, in: Circle())
                                    .offset(x: 3, y: -3)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Filter restaurants")
                .accessibilityIdentifier("restaurant-filter-button")
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal) {
                HStack(spacing: 4) {
                    ForEach(RestaurantFilter.quickFilters) { filter in
                        SearchChip(
                            title: filter.title,
                            isSelected: state.activeFilter == filter,
                            action: { state.selectFilter(state.activeFilter == filter ? nil : filter) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
}

private struct SearchChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            performSelection()
        } label: {
            Text(title)
                .font(BiteScoutFont.sans(14, relativeTo: .subheadline))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background(isSelected ? Color.accentColor : Color.biteScoutControlSurface, in: Capsule())
                .contentShape(Capsule())
                .transaction { $0.disablesAnimations = true }
        }
        .buttonStyle(BiteScoutInstantButtonStyle())
        .transaction { $0.disablesAnimations = true }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func performSelection() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
        BiteScoutHaptics.shared.play(.selection)
    }
}
