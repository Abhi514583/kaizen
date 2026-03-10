//
//  ContentView.swift
//  Kaizen
//
//  Created by Abhishek Thakur on 2026-03-10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \ExerciseSession.date, order: .reverse) private var sessions: [ExerciseSession]
    
    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kaizenShadow.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    KaizenHeader(dayText: Date().formatted(.dateTime.weekday(.abbreviated)))
                    
                    // Progression Stats Segment
                    HStack(spacing: UIConstants.Spacing.md) {
                        VStack(alignment: .leading) {
                            Text(profile?.currentSwordTier.rawValue ?? "Wooden")
                                .font(.kaizenSectionHeader)
                                .foregroundColor(.kaizenSage)
                            Text("Sword Tier")
                                .font(.kaizenMetadata)
                                .foregroundColor(.kaizenGray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(profile?.freezesRemaining ?? 8)")
                                .font(.kaizenSectionHeader)
                                .foregroundColor(.kaizenWood)
                            Text("Freezes Left")
                                .font(.kaizenMetadata)
                                .foregroundColor(.kaizenGray)
                        }
                    }
                    .padding(.horizontal, UIConstants.Spacing.md)
                    .padding(.bottom, UIConstants.Spacing.md)
                    
                    List {
                        ForEach(sessions) { session in
                            HStack {
                                Text("\(session.exerciseType.rawValue)")
                                    .font(.kaizenBody)
                                    .foregroundColor(.kaizenWhite)
                                Spacer()
                                Text("\(session.repsOrDuration) Reps")
                                    .font(.kaizenMetadata)
                                    .foregroundColor(.kaizenGray)
                            }
                            .listRowBackground(Color.kaizenShadow)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                ensureProfileExists()
                if let p = profile {
                    ProgressionManager.shared.processDailyCheck(profile: p, modelContext: modelContext)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    addMockSession()
                    if let p = profile {
                        ProgressionManager.shared.completeWorkout(profile: p, modelContext: modelContext)
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.kaizenShadow)
                        .padding(UIConstants.Spacing.md)
                        .background(Color.kaizenSage)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(UIConstants.Spacing.lg)
            }
        }
    }
    
    private func ensureProfileExists() {
        if profiles.isEmpty {
            let newProfile = UserProfile()
            let newProgress = SwordProgress()
            newProfile.progress = newProgress
            
            modelContext.insert(newProgress)
            modelContext.insert(newProfile)
            try? modelContext.save()
        }
    }

    private func addMockSession() {
        withAnimation {
            let session = ExerciseSession(exerciseType: .pushups, repsOrDuration: 15, targetForThatDay: 20, completed: true)
            modelContext.insert(session)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
