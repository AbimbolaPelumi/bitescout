import SwiftUI
import UIKit

extension Color {
    /// Figma Neutral/100 (#F1F3F3) on light surfaces, with a semantic dark-mode counterpart.
    static let biteScoutControlSurface = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? .secondarySystemBackground
                : UIColor(red: 241 / 255, green: 243 / 255, blue: 243 / 255, alpha: 1)
        }
    )

    /// Figma neutral divider (#ECEFF3) with the platform separator in dark mode.
    static let biteScoutDivider = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? .separator
                : UIColor(red: 236 / 255, green: 239 / 255, blue: 243 / 255, alpha: 1)
        }
    )
}
