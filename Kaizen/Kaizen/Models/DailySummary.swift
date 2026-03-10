import Foundation
import SwiftData

@Model
final class DailySummary {
    @Attribute(.unique) var date: Date
    var pushupsTotal: Int
    var squatsTotal: Int
    var plankTotal: Int
    var sessionsCompleted: Int
    var freezeUsed: Bool
    
    init(date: Date = Date(),
         pushupsTotal: Int = 0,
         squatsTotal: Int = 0,
         plankTotal: Int = 0,
         sessionsCompleted: Int = 0,
         freezeUsed: Bool = false) {
        
        // Strip out the time component
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        
        self.pushupsTotal = pushupsTotal
        self.squatsTotal = squatsTotal
        self.plankTotal = plankTotal
        self.sessionsCompleted = sessionsCompleted
        self.freezeUsed = freezeUsed
    }
}
