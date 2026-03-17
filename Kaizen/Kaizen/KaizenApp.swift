//
//  KaizenApp.swift
//  Kaizen
//
//  Created by Abhishek Thakur on 2026-03-10.
//

import SwiftUI
import SwiftData

@main
struct KaizenApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            ExerciseSession.self,
            DailySummary.self,
            SwordProgress.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var workoutManager = WorkoutManager()
    @State private var streakManager = StreakManager()
    @State private var progressManager = ProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutManager)
                .environment(streakManager)
                .environment(progressManager)
                .onAppear {
                    let context = sharedModelContainer.mainContext
                    workoutManager.setModelContext(context)
                    streakManager.setModelContext(context)
                    progressManager.setModelContext(context)
                    
                    // Connect services
                    workoutManager.setStreakManager(streakManager)
                    workoutManager.setProgressManager(progressManager)
                    streakManager.setProgressManager(progressManager)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
