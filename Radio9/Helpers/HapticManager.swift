import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        guard hapticFeedbackEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticFeedbackEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        guard hapticFeedbackEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}