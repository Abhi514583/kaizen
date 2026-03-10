import Foundation
import SwiftData

/// Represents the visual state of the user's sword aura
enum AuraState: String, Codable, CaseIterable {
    case none = "None"
    case faint = "Faint"
    case glowing = "Glowing"
    case radiant = "Radiant"
}

@Model
final class SwordProgress {
    var currentTier: SwordTier
    var completedCycles: Int
    var auraState: AuraState
    var lastTierUpgradeDate: Date?
    
    init(currentTier: SwordTier = .wooden,
         completedCycles: Int = 0,
         auraState: AuraState = .none,
         lastTierUpgradeDate: Date? = nil) {
        self.currentTier = currentTier
        self.completedCycles = completedCycles
        self.auraState = auraState
        self.lastTierUpgradeDate = lastTierUpgradeDate
    }
}
