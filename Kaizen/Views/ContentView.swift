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
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kaizenShadow.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    KaizenHeader(dayText: Date().formatted(.dateTime.weekday(.abbreviated)))
                    
                    List {
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                    .font(.kaizenBody)
                                    .foregroundColor(.kaizenWood)
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

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
