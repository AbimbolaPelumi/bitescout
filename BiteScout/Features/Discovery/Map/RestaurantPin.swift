import SwiftUI

struct RestaurantPin: View {
    let number: Int
    let isSelected: Bool

    private let amber = Color(red: 0.72, green: 0.43, blue: 0.03)

    var body: some View {
        VStack(spacing: -2) {
            Text(number.formatted())
                .font(BiteScoutFont.sans(13, weight: .bold, relativeTo: .footnote))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(isSelected ? amber : Color.accentColor, in: Circle())
            Triangle()
                .fill(isSelected ? amber : Color.accentColor)
                .frame(width: 10, height: 7)
        }
        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        .scaleEffect(isSelected ? 1.25 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .init(x: rect.midX, y: rect.maxY))
            path.addLine(to: .init(x: rect.minX, y: rect.minY))
            path.addLine(to: .init(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}
