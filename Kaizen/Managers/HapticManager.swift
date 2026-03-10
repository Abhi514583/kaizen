import UIKit

/// Centralized manager for executing standardized ritual haptic feedback
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Triggered when the user initiates a workout
    func playWorkoutStart() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggered when the user successfully finishes their daily reps
    func playSessionComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Triggered when the user's 30 day consistency levels them up a Sword tier
    func playSwordTierUnlock() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        // Follow up with success slightly delayed for a "grand" effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }
    }
    
    /// Triggered if the user misses a day and consumes a Freeze
    func playFreezeConsumed() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}
