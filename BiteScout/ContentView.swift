import SwiftUI

@MainActor
struct ContentView: View {
    @State private var selectedTab: AppTab = .search
    @State private var searchState = DiscoveryState()

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Search", systemImage: "magnifyingglass", value: .search) {
                    SearchTabView(state: $searchState)
                }

                Tab("Discover", systemImage: "rectangle.grid.1x2", value: .discover) {
                    PlaceholderTabView(tab: .discover)
                }

                Tab("Lists", systemImage: "bookmark", value: .lists) {
                    PlaceholderTabView(tab: .lists)
                }

                Tab("Account", systemImage: "person.circle", value: .account) {
                    PlaceholderTabView(tab: .account)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .tint(.accentColor)
            .disabled(searchState.isFilterSheetPresented)
            .accessibilityHidden(searchState.isFilterSheetPresented)

            if searchState.isFilterSheetPresented {
                SearchFilterSheet(state: $searchState)
                    .zIndex(10)
            }
        }
        .environment(\.font, BiteScoutFont.sans(17, relativeTo: .body))
        .onChange(of: selectedTab) { _, _ in
            BiteScoutHaptics.shared.play(.selection)
        }
    }
}

enum AppTab: String, CaseIterable, Hashable, Identifiable {
    case search
    case discover
    case lists
    case account

    var id: Self { self }

    var title: String {
        rawValue.capitalized
    }

    var systemImage: String {
        switch self {
        case .search: "magnifyingglass"
        case .discover: "rectangle.grid.1x2"
        case .lists: "bookmark"
        case .account: "person.circle"
        }
    }
}

private struct PlaceholderTabView: View {
    let tab: AppTab

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                tab.title,
                systemImage: tab.systemImage,
                description: Text("This section is coming soon.")
            )
            .navigationTitle(tab.title)
        }
    }
}

#Preview {
    ContentView()
}
