import CoreHaptics
import UIKit

@MainActor
final class BiteScoutHaptics {
    static let shared = BiteScoutHaptics()

    enum Event {
        case selection
        case lightImpact
        case mediumImpact
        case success
    }

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    private init() {
        prepare()
    }

    /// UIKit also respects the device's global System Haptics preference.
    var isEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: "BiteScoutHapticsEnabled") != nil else { return true }
            return UserDefaults.standard.bool(forKey: "BiteScoutHapticsEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BiteScoutHapticsEnabled")
        }
    }

    func play(_ event: Event) {
        guard isEnabled, supportsHaptics else { return }

        switch event {
        case .selection:
            selectionGenerator.selectionChanged()
            selectionGenerator.prepare()
        case .lightImpact:
            lightImpactGenerator.impactOccurred(intensity: 0.72)
            lightImpactGenerator.prepare()
        case .mediumImpact:
            mediumImpactGenerator.impactOccurred(intensity: 0.82)
            mediumImpactGenerator.prepare()
        case .success:
            notificationGenerator.notificationOccurred(.success)
            notificationGenerator.prepare()
        }
    }

    private func prepare() {
        selectionGenerator.prepare()
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        notificationGenerator.prepare()
    }
}
