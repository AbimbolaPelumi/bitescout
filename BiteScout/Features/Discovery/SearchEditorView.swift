import SwiftUI

struct SearchEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var state: DiscoveryState
    @State private var query: String
    @FocusState private var isQueryFocused: Bool

    private let trending = ["Izanagi", "Yellow Chilli", "SABOR Lagos"]

    init(state: Binding<DiscoveryState>) {
        _state = state
        _query = State(initialValue: state.wrappedValue.searchText)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    if query.searchTokens.isEmpty {
                        trendingContent
                    } else {
                        suggestionContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .top, spacing: 0) { searchFields }
            .safeAreaInset(edge: .bottom, spacing: 0) { submitButton }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: close) {
                        Image(systemName: "chevron.left")
                    }
                    .accessibilityLabel("Back")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { isQueryFocused = true }
    }

    private var searchFields: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("e.g Seafood on Friday night", text: $query)
                    .focused($isQueryFocused)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit(submit)
                    .accessibilityIdentifier("query-field")
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.biteScoutControlSurface, in: RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
                Text("Lagos, NG")
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.biteScoutControlSurface, in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Search location, Lagos, Nigeria")
        }
        .font(BiteScoutFont.sans(16, relativeTo: .body))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var trendingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trending in Lagos, NG")
                .font(BiteScoutFont.sans(18, weight: .bold, relativeTo: .headline))

            ForEach(trending, id: \.self) { term in
                Button(action: {
                    BiteScoutHaptics.shared.play(.selection)
                    query = term
                    isQueryFocused = true
                }) {
                    Label(term, systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .font(BiteScoutFont.sans(16, weight: .medium, relativeTo: .body))
                .frame(minHeight: 32)
            }
        }
    }

    private var suggestionContent: some View {
        ForEach(state.suggestions(for: query)) { restaurant in
            Button(action: { openDetails(restaurant.id) }) {
                SearchSuggestionRow(restaurant: restaurant)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("restaurant-suggestion")
        }
    }

    private var submitButton: some View {
        Button(action: submit) {
            Text("Search")
                .font(BiteScoutFont.sans(16, weight: .bold, relativeTo: .body))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.accentColor.opacity(query.searchTokens.isEmpty ? 0.24 : 1), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(query.searchTokens.isEmpty)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .accessibilityIdentifier("submit-search")
    }

    private func submit() {
        guard !query.searchTokens.isEmpty else { return }
        BiteScoutHaptics.shared.play(.success)
        state.submitSearch(query)
        dismiss()
    }

    private func openDetails(_ id: Restaurant.ID) {
        BiteScoutHaptics.shared.play(.lightImpact)
        state.focusResult(id)
        dismiss()
    }

    private func close() {
        state.isSearchEditorPresented = false
        dismiss()
    }
}

private struct SearchSuggestionRow: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            RestaurantImage(name: restaurant.imageName)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(restaurant.name)
                    .font(BiteScoutFont.sans(16, weight: .bold, relativeTo: .body))
                    .lineLimit(1)
                RestaurantMetadata(restaurant: restaurant, compact: true)
                RestaurantAddress(text: restaurant.fullAddress, compact: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 62)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens restaurant details")
    }
}
