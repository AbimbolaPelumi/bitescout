import SwiftUI

struct RestaurantImage: View {
    let name: String

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
            if name.isEmpty {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            } else {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        }
        .clipped()
    }
}
