import Foundation
import SwiftData

enum SwordTier: String, Codable, CaseIterable {
    case wooden = "Wooden"
    case steel = "Steel"
    case gold = "Gold"
    case shadow = "Shadow"
    
    var next: SwordTier? {
        switch self {
        case .wooden: return .steel
        case .steel: return .gold
        case .gold: return .shadow
        case .shadow: return nil
        }
    }
    
    var previous: SwordTier? {
        switch self {
        case .wooden: return nil
        case .steel: return .wooden
        case .gold: return .steel
        case .shadow: return .gold
        }
    }
}

@Model
final class UserProgression {
    var currentTier: SwordTier
    var cycleStartDate: Date
    var freezesUsed: Int
    var lastWorkoutDate: Date?
    
    init(currentTier: SwordTier = .wooden, 
         cycleStartDate: Date = Date(), 
         freezesUsed: Int = 0,
         lastWorkoutDate: Date? = nil) {
        self.currentTier = currentTier
        self.cycleStartDate = cycleStartDate
        self.freezesUsed = freezesUsed
        self.lastWorkoutDate = lastWorkoutDate
    }
    
    var freezesRemaining: Int {
        return max(0, 8 - freezesUsed)
    }
    
    var daysIntoCycle: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: cycleStartDate)
        let now = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: now)
        return (components.day ?? 0) + 1
    }
    
    var isCycleComplete: Bool {
        return daysIntoCycle >= 30
    }
}
