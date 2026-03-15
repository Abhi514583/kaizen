import Foundation
import SwiftData

/// Represents the primary user identity and high-level progression state.
@Model
final class UserProfile {
    var baselinePushups: Int
    var baselineSquats: Int
    var baselinePlank: Int
    
    var currentSwordTier: SwordTier
    var currentStreak: Int
    var freezesRemaining: Int
    var cycleStartDate: Date?
    var lastActivityDate: Date?
    var premiumStatus: Bool
    
    // Relationships
    var progress: SwordProgress?
    
    init(baselinePushups: Int = 0,
         baselineSquats: Int = 0,
         baselinePlank: Int = 0,
         currentSwordTier: SwordTier = .wooden,
         currentStreak: Int = 0,
         freezesRemaining: Int = 8,
         cycleStartDate: Date? = Date(),
         lastActivityDate: Date? = Date(),
         premiumStatus: Bool = false) {
        
        self.baselinePushups = baselinePushups
        self.baselineSquats = baselineSquats
        self.baselinePlank = baselinePlank
        self.currentSwordTier = currentSwordTier
        self.currentStreak = currentStreak
        self.freezesRemaining = freezesRemaining
        self.cycleStartDate = cycleStartDate
        self.lastActivityDate = lastActivityDate
        self.premiumStatus = premiumStatus
    }
}
