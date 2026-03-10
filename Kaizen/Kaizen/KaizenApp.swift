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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
