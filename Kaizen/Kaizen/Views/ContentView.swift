//
//  ContentView.swift
//  Kaizen
//
//  Created by Abhishek Thakur on 2026-03-10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var navigationPath: [KaizenRoute] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(path: $navigationPath)
                .navigationDestination(for: KaizenRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView(path: $navigationPath)
                    case .calendar(let tier):
                        CalendarView(tier: tier)
                    case .improvement:
                        ImprovementView()
                    case .settings:
                        SettingsView()
                    case .workoutSetup(let type):
                        WorkoutSetupView(path: $navigationPath, exerciseType: type)
                    case .activeWorkout(let type):
                        WorkoutView(path: $navigationPath, exerciseName: type.rawValue, pr: "", goal: 0)
                    case .sessionComplete(let type, let count):
                        SessionCompleteView(path: $navigationPath, exerciseType: type, count: count)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
