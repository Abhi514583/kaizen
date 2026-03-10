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
