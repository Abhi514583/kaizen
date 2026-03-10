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
    @Query private var progressions: [UserProgression]
    @Query private var items: [Item]
    
    private var progression: UserProgression? {
        progressions.first
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
                            Text(progression?.currentTier.rawValue ?? "Wooden")
                                .font(.kaizenSectionHeader)
                                .foregroundColor(.kaizenSage)
                            Text("Sword Tier")
                                .font(.kaizenMetadata)
                                .foregroundColor(.kaizenGray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(progression?.freezesRemaining ?? 8)")
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
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                    .font(.kaizenBody)
                                    .foregroundColor(.kaizenWhite)
                            }
                            .listRowBackground(Color.kaizenShadow)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                ensureProgressionExists()
                if let p = progression {
                    ProgressionManager.shared.processDailyCheck(progression: p, modelContext: modelContext)
                }
            }
            .navigationDestination(for: Item.self) { item in
                ZStack {
                    Color.kaizenShadow.ignoresSafeArea()
                    Text("Selected: \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        .font(.kaizenSectionHeader)
                        .foregroundColor(.kaizenWhite)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    addItem()
                    if let p = progression {
                        ProgressionManager.shared.completeWorkout(progression: p, modelContext: modelContext)
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
    
    private func ensureProgressionExists() {
        if progressions.isEmpty {
            let newProgression = UserProgression()
            modelContext.insert(newProgression)
            try? modelContext.save()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
