import SwiftUI

struct SearchFilterSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var state: DiscoveryState
    @State private var draft: SearchFilters
    @State private var isVisible = false
    @State private var isDismissing = false
    @State private var dragOffset: CGFloat = 0
    @State private var hasCrossedDismissThreshold = false

    private let cuisines = [
        "Nigerian", "American", "Asian", "Brazilian", "Chinese", "French", "Indian",
        "Italian", "Korean", "Mediterranean", "Pizza", "Seafood", "Steakhouse", "Sushi"
    ]

    init(state: Binding<DiscoveryState>) {
        _state = state
        _draft = State(initialValue: state.wrappedValue.appliedFilters)
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = max(72, proxy.safeAreaInsets.top + 13)
            let cardHeight = max(0, min(770, proxy.size.height - topInset - 32))
            let dismissalProgress = min(dragOffset / max(cardHeight * 0.42, 1), 1)
            let hiddenOffset = proxy.size.height - topInset + 40
            let cardOffset = reduceMotion ? 0 : (isVisible ? dragOffset : hiddenOffset)

            ZStack(alignment: .top) {
                Color.black
                    .opacity(isVisible ? 0.56 * (1 - dismissalProgress) : 0)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { dismissModal() }

                modalCard
                    .frame(width: max(0, min(370, proxy.size.width - 32)), height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .shadow(color: Color.black.opacity(isVisible ? 0.18 : 0), radius: 18, y: 8)
                    .padding(.top, topInset)
                    .offset(y: cardOffset)
                    .opacity(isVisible ? 1 : (reduceMotion ? 0 : 1))
            }
        }
        // A full-screen custom modal must measure from the physical screen edges.
        // Otherwise GeometryReader starts below the presentation safe area and
        // effectively adds the top inset twice.
        .ignoresSafeArea()
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { dismissModal() }
        .onAppear {
            Task { @MainActor in
                await Task.yield()
                withAnimation(presentationAnimation) {
                    isVisible = true
                }
            }
        }
    }

    private var modalCard: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 0) {
                    FilterSection(title: "Sort by", topPadding: 4) { sortPicker }
                    FilterSection(title: "Rating") { ratingChips }
                    FilterSection(title: "Restaurant type") { restaurantTypeChips }
                    FilterSection(title: "Pricing") { priceChips }
                    FilterSection(title: "Cuisine type", showsDivider: false) { cuisineChips }
                }
                .padding(.horizontal, 32)
            }
            .scrollIndicators(.hidden)

            footer
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("Filters")
                .font(BiteScoutFont.sans(18, weight: .bold, relativeTo: .headline))
            Spacer()
            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.biteScoutControlSurface, in: Circle())
            }
            .buttonStyle(BiteScoutPressStyle())
            .accessibilityLabel("Close filters")
        }
        .frame(height: 36)
        .padding(.horizontal, 32)
        .padding(.top, 26)
        .padding(.bottom, 18)
        .contentShape(Rectangle())
        .simultaneousGesture(sheetDragGesture)
    }

    private var sortPicker: some View {
        HStack(spacing: 0) {
            ForEach(SearchSort.allCases) { sort in
                Button {
                    selectSort(sort)
                } label: {
                    Text(sort.rawValue)
                        .font(BiteScoutFont.sans(14, relativeTo: .subheadline))
                        .foregroundStyle(draft.sort == sort ? Color.white : Color.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(draft.sort == sort ? Color.accentColor : Color.clear, in: Capsule())
                        .transaction { $0.disablesAnimations = true }
                }
                .buttonStyle(BiteScoutInstantButtonStyle())
                .accessibilityAddTraits(draft.sort == sort ? .isSelected : [])
            }
        }
        .padding(2)
        .frame(height: 36)
        .background(Color.biteScoutControlSurface, in: Capsule())
        .transaction { $0.disablesAnimations = true }
    }

    private var ratingChips: some View {
        FlowLayout(spacing: 8) {
            ForEach((1...5).reversed(), id: \.self) { rating in
                FilterChip(title: "\(rating) star\(rating == 1 ? "" : "s")", isSelected: draft.ratings.contains(rating)) {
                    toggle(rating, in: &draft.ratings)
                }
            }
            FilterChip(title: "Unrated", isSelected: draft.includesUnrated) {
                draft.includesUnrated.toggle()
            }
        }
    }

    private var restaurantTypeChips: some View {
        FlowLayout(spacing: 8) {
            ForEach(RestaurantFilter.sheetFilters) { filter in
                FilterChip(title: filter.title, isSelected: draft.restaurantTypes.contains(filter)) {
                    toggle(filter, in: &draft.restaurantTypes)
                }
                .accessibilityIdentifier("filter-type-\(filter.rawValue)")
            }
        }
    }

    private var priceChips: some View {
        FlowLayout(spacing: 8) {
            ForEach(1...4, id: \.self) { price in
                FilterChip(title: String(repeating: "$", count: price), isSelected: draft.priceLevels.contains(price)) {
                    toggle(price, in: &draft.priceLevels)
                }
            }
        }
    }

    private var cuisineChips: some View {
        FlowLayout(spacing: 8) {
            ForEach(cuisines, id: \.self) { cuisine in
                FilterChip(title: cuisine, isSelected: draft.cuisines.contains(cuisine)) {
                    toggle(cuisine, in: &draft.cuisines)
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            ModalActionButton(title: "Clear all", isPrimary: false) {
                draft.clear()
                BiteScoutHaptics.shared.play(.lightImpact)
            }
            ModalActionButton(title: "Apply filters", isPrimary: true) {
                state.applyFilters(draft)
                BiteScoutHaptics.shared.play(.success)
                dismissModal(playsHaptic: false)
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
        .background(Color(.systemBackground))
    }

    private func close() {
        dismissModal()
    }

    private func toggle<Value: Hashable>(_ value: Value, in set: inout Set<Value>) {
        if set.contains(value) { set.remove(value) } else { set.insert(value) }
    }

    private func selectSort(_ sort: SearchSort) {
        guard draft.sort != sort else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            draft.sort = sort
        }
        BiteScoutHaptics.shared.play(.selection)
    }

    private var sheetDragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged { value in
                guard !isDismissing else { return }
                let newOffset = max(0, value.translation.height)
                let crossedThreshold = newOffset >= 120

                if crossedThreshold != hasCrossedDismissThreshold {
                    BiteScoutHaptics.shared.play(.selection)
                    hasCrossedDismissThreshold = crossedThreshold
                }

                dragOffset = newOffset
            }
            .onEnded { value in
                guard !isDismissing else { return }
                let shouldDismiss = dragOffset > 120 || value.predictedEndTranslation.height > 220

                if shouldDismiss {
                    dismissModal(playsHaptic: !hasCrossedDismissThreshold)
                } else {
                    withAnimation(snapBackAnimation) {
                        dragOffset = 0
                    }
                    hasCrossedDismissThreshold = false
                }
            }
    }

    private var presentationAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.14)
            : .spring(response: 0.42, dampingFraction: 0.86, blendDuration: 0.1)
    }

    private var snapBackAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.34, dampingFraction: 0.82, blendDuration: 0.08)
    }

    private func dismissModal(playsHaptic: Bool = true) {
        guard !isDismissing else { return }
        isDismissing = true

        if playsHaptic {
            BiteScoutHaptics.shared.play(.lightImpact)
        }

        withAnimation(presentationAnimation) {
            isVisible = false
            dragOffset = 0
        }
        hasCrossedDismissThreshold = false

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 140 : 320))
            state.isFilterSheetPresented = false
        }
    }
}

private struct FilterSection<Content: View>: View {
    let title: String
    var topPadding: CGFloat = 20
    var showsDivider = true
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(BiteScoutFont.sans(16, weight: .bold, relativeTo: .headline))
            content
        }
        .padding(.top, topPadding)
        .padding(.bottom, 20)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(Color.biteScoutDivider)
                    .frame(height: 1)
            }
        }
    }
}

private struct FilterChip: View {
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
                .frame(height: 34)
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

private struct ModalActionButton: View {
    let title: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(BiteScoutFont.sans(16, weight: .bold, relativeTo: .body))
            .foregroundStyle(isPrimary ? Color.white : Color.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isPrimary ? Color.accentColor : Color(.systemBackground), in: Capsule())
            .overlay {
                if !isPrimary { Capsule().stroke(Color(.separator), lineWidth: 0.5) }
            }
            .buttonStyle(BiteScoutPressStyle())
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, point) in result.points.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, points: [CGPoint]) {
        let maxWidth = proposal.width ?? 306
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var points: [CGPoint] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (CGSize(width: maxWidth, height: y + lineHeight), points)
    }
}
