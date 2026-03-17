import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(StreakManager.self) private var streakManager
    @Environment(ProgressManager.self) private var progressManager
    @Query private var profiles: [UserProfile]
    @Query(sort: \ExerciseSession.date, order: .reverse) private var sessions: [ExerciseSession]
    @Query(sort: \DailySummary.date, order: .reverse) private var summaries: [DailySummary]

    @Binding var path: [KaizenRoute]

    @State private var isMenuExpanded = false
    @State private var selectedTarget: ExerciseTarget? = nil
    @State private var animateHearts = false
    @State private var revealHero = false

    private var profile: UserProfile? {
        profiles.first
    }

    private var todaySummary: DailySummary? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return summaries.first(where: { calendar.isDate($0.date, inSameDayAs: today) })
    }

    private var realTargets: [ExerciseTarget] {
        [
            ExerciseTarget(id: ExerciseType.pushups.rawValue, type: .pushups, name: "Pushups", current: todaySummary?.pushupsTotal ?? 0, goal: progressManager.calculateDailyTarget(for: .pushups, on: Date(), profile: profile), color: .kaizenSage),
            ExerciseTarget(id: ExerciseType.squats.rawValue, type: .squats, name: "Squats", current: todaySummary?.squatsTotal ?? 0, goal: progressManager.calculateDailyTarget(for: .squats, on: Date(), profile: profile), color: .kaizenWood),
            ExerciseTarget(id: ExerciseType.plank.rawValue, type: .plank, name: "Plank", current: todaySummary?.plankTotal ?? 0, goal: progressManager.calculateDailyTarget(for: .plank, on: Date(), profile: profile), color: .kaizenGray)
        ]
    }

    private var currentStreak: Int {
        profile?.currentStreak ?? 0
    }

    private var freezesRemaining: Int {
        profile?.freezesRemaining ?? 8
    }

    private var ritualStatus: RitualDotStatus {
        let targets = realTargets
        if let todaySummary,
           let profile,
           progressManager.isDailyRitualComplete(summary: todaySummary, profile: profile, on: Date()) {
            return .completed
        }

        let completed = targets.filter { $0.current >= $0.goal }.count
        if completed == targets.count {
            return .completed
        } else if targets.contains(where: { $0.current > 0 }) {
            return .inProgress
        } else {
            return .notStarted
        }
    }

    private var ritualCompletionRatio: Double {
        let totals = realTargets.reduce(0.0) { partial, target in
            guard target.goal > 0 else { return partial }
            return partial + min(Double(target.current) / Double(target.goal), 1.0)
        }

        return totals / Double(max(realTargets.count, 1))
    }

    private var ritualStatusCopy: String {
        switch ritualStatus {
        case .completed:
            return "Daily ritual complete"
        case .inProgress:
            return "Momentum is building"
        case .notStarted:
            return "Ready to begin"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.11, blue: 0.11),
                    Color(red: 0.14, green: 0.16, blue: 0.15),
                    Color(red: 0.07, green: 0.08, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RainAtmosphere()
                .ignoresSafeArea()

            Circle()
                .fill(Color.kaizenMint.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 60, y: 240)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    KaizenHeader(
                        isHome: true,
                        tier: profile?.currentSwordTier.rawValue.capitalized ?? "Wooden",
                        aura: profile?.progress?.auraState.rawValue.capitalized ?? "None",
                        onSettingsTap: { path.append(.settings) }
                    )
                    .padding(.top, 10)

                    heroSection
                        .scaleEffect(revealHero ? 1.0 : 0.96)
                        .opacity(revealHero ? 1.0 : 0.0)

                    targetsSection

                    bottomNavBar
                        .padding(.top, 8)
                        .padding(.bottom, UIConstants.Spacing.lg)
                }
                .padding(.top, 6)
            }

            if isMenuExpanded {
                menuOverlay
            }
        }
        .onAppear {
            ensureProfileExists()
            if let profile = profile {
                streakManager.validateDailyStreak(profile: profile)
                progressManager.checkCycleCompletion(profile: profile)
            }

            animateHearts = true
            withAnimation(.spring(response: 0.72, dampingFraction: 0.84)) {
                revealHero = true
            }
        }
        .sheet(item: $selectedTarget) { target in
            TargetDetailSheet(target: target, type: target.type, workoutManager: workoutManager, path: $path)
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Date().formatted(.dateTime.weekday(.wide)).uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenFog.opacity(0.62))
                        .tracking(2)

                    HStack(alignment: .lastTextBaseline, spacing: 12) {
                        FlipClockHero(value: currentStreak)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("DAY STREAK")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.kaizenCloud)
                                .tracking(2)

                            HStack(spacing: 10) {
                                RitualDot(status: ritualStatus)
                                Text(ritualStatusCopy)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.kaizenFog.opacity(0.78))
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(Int(ritualCompletionRatio * 100))%")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.kaizenMint)
                        .contentTransition(.numericText())

                    Text("TODAY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenFog.opacity(0.56))
                        .tracking(1.8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .kaizenFloatingCapsule(tint: Color.kaizenMint.opacity(0.10))
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("FREEZE HEARTS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenFog.opacity(0.56))
                        .tracking(1.8)
                    Spacer()
                    Text("\(freezesRemaining) / 8")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.kaizenCloud)
                }

                freezeRow
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("RITUAL FLOW")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenFog.opacity(0.56))
                        .tracking(1.8)
                    Spacer()
                    Text("\(realTargets.filter { $0.current > 0 }.count) / \(realTargets.count) active")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.kaizenCloud)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.05))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.kaizenMint, Color.kaizenSage],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(20, proxy.size.width * ritualCompletionRatio))
                            .shadow(color: Color.kaizenMint.opacity(0.18), radius: 12, x: 0, y: 0)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(22)
        .kaizenGlassCard(cornerRadius: 34, tint: Color.kaizenMint.opacity(0.08))
        .padding(.horizontal, UIConstants.Spacing.lg)
    }

    private var freezeRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: index < freezesRemaining ? "heart.fill" : "heart")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(index < freezesRemaining ? .kaizenEmber : .kaizenFog.opacity(0.26))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(index < freezesRemaining ? Color.kaizenEmber.opacity(0.12) : Color.white.opacity(0.03))
                    )
                    .scaleEffect(index < freezesRemaining && animateHearts ? 1.08 : 0.96)
                    .animation(
                        index < freezesRemaining
                        ? .easeInOut(duration: 0.95).repeatForever(autoreverses: true).delay(Double(index) * 0.08)
                        : .default,
                        value: animateHearts
                    )
            }
            Spacer()
        }
    }

    private var targetsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("DAILY RITUAL")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.kaizenFog.opacity(0.58))
                    .tracking(2)
                Spacer()
            }
            .padding(.leading, 4)

            VStack(spacing: 12) {
                ForEach(realTargets) { target in
                    ExerciseTargetCard(target: target) {
                        HapticManager.shared.playWorkoutStart()
                        selectedTarget = target
                    }
                }
            }
        }
        .padding(.horizontal, UIConstants.Spacing.lg)
    }

    private var bottomNavBar: some View {
        HStack {
            Button(action: { path.append(.improvement) }) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .semibold))
                    Text("PROGRESS")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1)
                }
                .foregroundColor(.kaizenFog)
                .frame(width: 92, height: 72)
                .kaizenFloatingCapsule(tint: Color.white.opacity(0.06))
            }

            Spacer()

            KaizenPlusButton(isExpanded: isMenuExpanded) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isMenuExpanded.toggle()
                }
            }
            .offset(y: -12)

            Spacer()

            Button(action: { path.append(.calendar(profile?.currentSwordTier.rawValue ?? "Wooden")) }) {
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .semibold))
                    Text("CALENDAR")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1)
                }
                .foregroundColor(.kaizenFog)
                .frame(width: 92, height: 72)
                .kaizenFloatingCapsule(tint: Color.white.opacity(0.06))
            }
        }
        .padding(.horizontal, 32)
    }

    private var menuOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    closeMenu()
                }

            VStack(spacing: 20) {
                Spacer()

                if isMenuExpanded {
                    VStack(spacing: 16) {
                        menuItem(title: "Pushups", pr: bestLabel(for: .pushups), icon: "figure.pushups", delay: 0.1) {
                            closeMenu()
                            path.append(.workoutSetup(.pushups))
                        }

                        menuItem(title: "Squats", pr: bestLabel(for: .squats), icon: "figure.cross.training", delay: 0.05) {
                            closeMenu()
                            path.append(.workoutSetup(.squats))
                        }

                        menuItem(title: "Plank", pr: bestLabel(for: .plank), icon: "figure.strengthtraining.functional", delay: 0.0) {
                            closeMenu()
                            path.append(.workoutSetup(.plank))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Button(action: {
                    closeMenu()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.kaizenCloud)
                            .frame(width: 78, height: 78)

                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.kaizenShadow)
                            .rotationEffect(.degrees(45))
                    }
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 25)
            }
        }
    }

    private func menuItem(title: String, pr: String, icon: String, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.playSessionComplete()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title.uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .tracking(2)

                    Text(pr)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.kaizenSage)
                }
            }
            .foregroundColor(.kaizenWhite)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .kaizenFloatingCapsule(tint: Color.white.opacity(0.08))
        }
        .scaleEffect(isMenuExpanded ? 1.0 : 0.8)
        .opacity(isMenuExpanded ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay), value: isMenuExpanded)
    }

    private func closeMenu() {
        HapticManager.shared.playWorkoutStart()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isMenuExpanded = false
        }
    }

    private func bestLabel(for type: ExerciseType) -> String {
        let best = progressManager.currentBest(for: type)
        guard best > 0 else { return "NO PR" }

        if type == .plank {
            return String(format: "%d:%02d PR", best / 60, best % 60)
        }

        return "\(best) PR"
    }

    private func ensureProfileExists() {
        // Defensive check to avoid duplicate insertion if onAppear fires multiple times rapidly
        let descriptor = FetchDescriptor<UserProfile>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0

        if existingCount == 0 && profiles.isEmpty {
            let newProfile = UserProfile()
            let newProgress = SwordProgress()
            newProfile.progress = newProgress

            modelContext.insert(newProgress)
            modelContext.insert(newProfile)
            try? modelContext.save()
        }
    }
}
