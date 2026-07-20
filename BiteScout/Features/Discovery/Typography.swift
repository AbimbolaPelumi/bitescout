import SwiftUI
import UIKit

enum BiteScoutFont {
    static func sans(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo style: Font.TextStyle
    ) -> Font {
        .custom(instrumentSansName(for: weight), size: size, relativeTo: style)
    }

    private static func instrumentSansName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black:
            "InstrumentSans-Regular_Bold"
        case .semibold:
            "InstrumentSans-Regular_SemiBold"
        case .medium:
            "InstrumentSans-Regular_Medium"
        default:
            "InstrumentSans-Regular"
        }
    }

    @MainActor
    static func configureNativeChrome() {
        let regular = UIFont(name: "InstrumentSans-Regular", size: 10)
        let medium = UIFont(name: "InstrumentSans-Regular_Medium", size: 10)
        let semibold = UIFont(name: "InstrumentSans-Regular_SemiBold", size: 17)
        let largeTitle = UIFont(name: "InstrumentSans-Regular_Bold", size: 34)

        if let regular {
            UITabBarItem.appearance().setTitleTextAttributes([.font: regular], for: .normal)
        }
        if let medium {
            UITabBarItem.appearance().setTitleTextAttributes([.font: medium], for: .selected)
        }
        if let semibold {
            UINavigationBar.appearance().titleTextAttributes = [.font: semibold]
        }
        if let largeTitle {
            UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitle]
        }
    }
}

struct BiteScoutPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// A button style with no system pressed-state opacity or animation.
/// Use for controls whose selected foreground and background must change
/// atomically, such as chips and segmented controls.
struct BiteScoutInstantButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
