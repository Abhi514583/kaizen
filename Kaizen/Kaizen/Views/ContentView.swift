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
                    case .calendar:
                        CalendarView()
                    case .improvement:
                        ImprovementView()
                    case .settings:
                        SettingsView()
                    case .workoutSetup:
                        WorkoutSetupView(path: $navigationPath)
                    case .activeWorkout:
                        UserWorkoutFlowView(path: $navigationPath)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
