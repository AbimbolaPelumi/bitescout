import SwiftUI

@MainActor
struct SearchTabView: View {
    @Binding private var state: DiscoveryState
    @State private var path: [SearchRoute] = []

    init(state: Binding<DiscoveryState>) {
        _state = state
    }

    var body: some View {
        NavigationStack(path: $path) {
            SearchLandingView(
                state: $state,
                onOpenSearch: {
                    BiteScoutHaptics.shared.play(.lightImpact)
                    state.isSearchEditorPresented = true
                },
                onOpenFilters: {
                    BiteScoutHaptics.shared.play(.lightImpact)
                    state.isFilterSheetPresented = true
                },
                onOpenRestaurant: {
                    BiteScoutHaptics.shared.play(.lightImpact)
                    state.presentedRestaurantID = $0
                }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case .map:
                    DiscoveryMapView(state: $state)
                }
            }
        }
        .fullScreenCover(isPresented: $state.isSearchEditorPresented, onDismiss: openSelectedSuggestion) {
            SearchEditorView(state: $state)
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { state.presentedRestaurantID != nil },
                set: { if !$0 { state.presentedRestaurantID = nil } }
            )
        ) {
            if let restaurantID = state.presentedRestaurantID {
                RestaurantDetailsView(state: $state, restaurantID: restaurantID)
            }
        }
    }

    private func openSelectedSuggestion() {
        guard let id = state.suggestionSelectionID else { return }
        state.suggestionSelectionID = nil
        state.presentedRestaurantID = id
    }
}

#Preview("Search — Landing") {
    @Previewable @State var state = DiscoveryState()
    SearchTabView(state: $state)
}

#Preview("Search — Results") {
    @Previewable @State var state = DiscoveryState(
        searchText: "Seafood on Friday night",
        presentation: .results
    )
    SearchTabView(state: $state)
}
