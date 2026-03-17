//
//  KaizenTests.swift
//  KaizenTests
//
//  Created by Abhishek Thakur on 2026-03-10.
//

import Testing
import SwiftData
@testable import Kaizen

struct KaizenTests {

    @MainActor
    @Test func dailyTargetUsesBaselineWhenNoPriorSession() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let profile = UserProfile(baselinePushups: 12)
        context.insert(profile)
        try context.save()

        let progressManager = ProgressManager(modelContext: context)

        let target = progressManager.calculateDailyTarget(for: .pushups, on: Date(), profile: profile)

        #expect(target == 12)
    }

    @MainActor
    @Test func dailyTargetStaysStableForTheSameDay() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let profile = UserProfile()
        context.insert(profile)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        context.insert(ExerciseSession(date: yesterday, exerciseType: .pushups, repsOrDuration: 20, targetForThatDay: 20, completed: true))
        try context.save()

        let progressManager = ProgressManager(modelContext: context)
        let targetBeforeTodaySave = progressManager.calculateDailyTarget(for: .pushups, on: today, profile: profile)
        context.insert(ExerciseSession(date: today, exerciseType: .pushups, repsOrDuration: 25, targetForThatDay: targetBeforeTodaySave, completed: true))
        try context.save()

        let targetAfterTodaySave = progressManager.calculateDailyTarget(for: .pushups, on: today, profile: profile)

        #expect(targetBeforeTodaySave == 21)
        #expect(targetAfterTodaySave == 21)
    }

    @MainActor
    @Test func streakOnlyAdvancesWhenFullRitualIsComplete() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let profile = UserProfile(baselinePushups: 10, baselineSquats: 10, baselinePlank: 10)
        context.insert(profile)
        let partialSummary = DailySummary(date: Date(), pushupsTotal: 10, squatsTotal: 0, plankTotal: 0, sessionsCompleted: 1)
        context.insert(partialSummary)
        try context.save()

        let progressManager = ProgressManager(modelContext: context)
        let streakManager = StreakManager(modelContext: context)
        streakManager.setProgressManager(progressManager)

        streakManager.onActivityCompleted(profile: profile)
        #expect(profile.currentStreak == 0)

        partialSummary.squatsTotal = 10
        partialSummary.plankTotal = 10
        partialSummary.sessionsCompleted = 3
        try context.save()

        streakManager.onActivityCompleted(profile: profile)
        #expect(profile.currentStreak == 1)
    }

    @MainActor
    @Test func missedDayConsumesFreezeOnlyOnce() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let twoDaysAgo = try #require(calendar.date(byAdding: .day, value: -2, to: today))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        let profile = UserProfile(currentStreak: 3, freezesRemaining: 2, lastActivityDate: twoDaysAgo)
        context.insert(profile)
        try context.save()

        let progressManager = ProgressManager(modelContext: context)
        let streakManager = StreakManager(modelContext: context)
        streakManager.setProgressManager(progressManager)

        streakManager.validateDailyStreak(profile: profile)
        let freezesAfterFirstValidation = profile.freezesRemaining
        let lastTrackedDateAfterFirstValidation = profile.lastActivityDate

        streakManager.validateDailyStreak(profile: profile)

        #expect(freezesAfterFirstValidation == 1)
        #expect(profile.freezesRemaining == 1)
        #expect(lastTrackedDateAfterFirstValidation == yesterday)
    }

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @MainActor
    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            ExerciseSession.self,
            DailySummary.self,
            SwordProgress.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
