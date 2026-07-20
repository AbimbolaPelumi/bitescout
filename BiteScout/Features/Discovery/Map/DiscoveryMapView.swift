import MapKit
import SwiftUI

@MainActor
struct DiscoveryMapView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var state: DiscoveryState
    @State private var cameraPosition: MapCameraPosition

    init(state: Binding<DiscoveryState>) {
        _state = state
        _cameraPosition = State(
            initialValue: .region(Self.region(for: state.wrappedValue.selectedRestaurant))
        )
    }

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(state.visibleRestaurants) { restaurant in
                Annotation("", coordinate: restaurant.coordinate, anchor: .bottom) {
                    Button(action: { selectRestaurant(restaurant.id) }) {
                        RestaurantPin(
                            number: restaurant.pinNumber,
                            isSelected: state.selectedRestaurantID == restaurant.id
                        )
                    }
                    .buttonStyle(.plain)
                    .zIndex(state.selectedRestaurantID == restaurant.id ? 1 : 0)
                    .accessibilityLabel("\(restaurant.name), rating \(restaurant.rating) stars")
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .bottom, spacing: 8) {
            RestaurantCarousel(
                restaurants: state.visibleRestaurants,
                selectedRestaurantID: selectedRestaurantBinding
            )
            .padding(.bottom, 8)
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: state.selectedRestaurantID) { _, _ in
            centerOnSelection()
        }
    }

    private var selectedRestaurantBinding: Binding<Restaurant.ID?> {
        Binding(
            get: { state.selectedRestaurantID },
            set: { newValue in
                guard let newValue else { return }
                state.selectRestaurant(newValue)
            }
        )
    }

    private func selectRestaurant(_ id: Restaurant.ID) {
        guard state.selectedRestaurantID != id else { return }
        BiteScoutHaptics.shared.play(.selection)
        state.selectRestaurant(id)
    }

    private func centerOnSelection() {
        guard let restaurant = state.selectedRestaurant else { return }

        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeInOut(duration: 0.4)) {
            cameraPosition = .region(Self.region(for: restaurant))
        }
    }

    private static func region(for restaurant: Restaurant?) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: restaurant?.coordinate ?? CLLocationCoordinate2D(latitude: 6.4281, longitude: 3.4219),
            span: MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
        )
    }
}

#Preview("Map — Selected Restaurant") {
    @Previewable @State var state = DiscoveryState()

    NavigationStack {
        DiscoveryMapView(state: $state)
    }
}
