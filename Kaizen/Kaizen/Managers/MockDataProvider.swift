import Foundation
import SwiftUI

struct MockDataProvider {
    // MARK: - User Profile & Progress
    static let mockStreak = 12 // Increasing it slightly for the "Mock" feel
    
    static var mockUserProfile: UserProfile {
        let profile = UserProfile()
        profile.currentStreak = 12
        profile.freezesRemaining = 5
        profile.currentSwordTier = .wooden
        
        let progress = SwordProgress()
        progress.currentTier = .wooden
        progress.auraState = .none
        profile.progress = progress
        
        return profile
    }
    
    // MARK: - Exercise Targets
    static var mockTargets: [ExerciseTarget] {
        [
            ExerciseTarget(id: "pushups_mock", type: .pushups, name: "Pushups", current: 30, goal: 30, color: .kaizenSage),
            ExerciseTarget(id: "squats_mock", type: .squats, name: "Squats", current: 20, goal: 50, color: .kaizenWood),
            ExerciseTarget(id: "plank_mock", type: .plank, name: "Plank", current: 45, goal: 60, color: .kaizenGray)
        ]
    }
    
    // MARK: - Performance Data
    struct PerformanceMock: Identifiable {
        let id = UUID()
        let title: String
        let baseline: Int
        let current: Int
        let trend: [Double]
        let icon: String
        let isTime: Bool
    }
    
    static var mockPerformance: [PerformanceMock] {
        [
            PerformanceMock(title: "Pushups", baseline: 12, current: 35, trend: [0.2, 0.35, 0.3, 0.5, 0.6, 0.85, 1.0], icon: "figure.pushups", isTime: false),
            PerformanceMock(title: "Squats", baseline: 20, current: 45, trend: [0.1, 0.25, 0.4, 0.35, 0.55, 0.7, 0.9], icon: "figure.cross.training", isTime: false),
            PerformanceMock(title: "Plank", baseline: 45, current: 120, trend: [0.3, 0.4, 0.35, 0.6, 0.5, 0.8, 1.0], icon: "figure.strengthtraining.functional", isTime: true)
        ]
    }
    
    // MARK: - Calendar History
    static func generateMockHistory() -> [RitualDay] {
        var mockDays: [RitualDay] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for i in 0..<365 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let status: RitualStatus
                if i == 0 { status = .inProgress }
                else if i % 15 == 0 { status = .missed }
                else if i % 7 == 0 { status = .freeze }
                else { status = .success }
                
                let stats: [String: SessionStats] = [
                    "Pushups": SessionStats(volume: 50 + Int.random(in: -10...20), maxShot: 35 + Int.random(in: -5...10), goal: 50),
                    "Squats": SessionStats(volume: 60 + Int.random(in: -5...15), maxShot: 40 + Int.random(in: -5...10), goal: 60),
                    "Plank": SessionStats(volume: 120 + Int.random(in: -20...40), maxShot: 90 + Int.random(in: -10...30), goal: 120)
                ]
                
                let mockSessionsCompleted = status == .success ? Int.random(in: 1...3) : 0
                
                mockDays.append(RitualDay(id: UUID(), date: date, status: status, stats: stats, sessionsCompleted: mockSessionsCompleted))
            }
        }
        return mockDays.reversed()
    }
}
