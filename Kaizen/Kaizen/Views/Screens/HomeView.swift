import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \ExerciseSession.date, order: .reverse) private var sessions: [ExerciseSession]
    
    @Binding var path: [KaizenRoute]
    
    @State private var isMenuExpanded = false
    @State private var auraOffset = CGSize.zero
    @State private var heartOffsets: [CGSize] = Array(repeating: .zero, count: 8)
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    // Mock data for Sprint 1
    private let mockStreak = 10
    private let weekday = Date().formatted(.dateTime.weekday(.wide))
    
    private let mockTargets = [
        ExerciseTarget(name: "Pushups", current: 30, goal: 30, color: .kaizenSage),
        ExerciseTarget(name: "Squats", current: 20, goal: 50, color: .kaizenWood),
        ExerciseTarget(name: "Plank", current: 45, goal: 60, color: .kaizenGray)
    ]

    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            // MARK: - Atmospheric Layer
            RainAtmosphere()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Master Identity Header
                KaizenHeader(
                    isHome: true,
                    tier: "Wooden",
                    aura: "Muted",
                    onSettingsTap: { path.append(.settings) }
                )
                .padding(.top, 10)
                
                // MARK: - Streak Section
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAY")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.kaizenGray)
                            .tracking(1)
                        
                        HStack(alignment: .bottom, spacing: 10) {
                            FlipClockHero(value: mockStreak)
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .padding(.bottom, 12)
                        }
                        
                        freezeRow
                            .padding(.top, 8)
                            .padding(.leading, -16) // Reset alignment relative to the VStack
                    }
                    Spacer()
                }
                .padding(.horizontal, UIConstants.Spacing.lg)
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: - Today's Ritual Targets
                targetsSection
                
                Spacer()
                
                // MARK: - Bottom Navigation
                bottomNavBar
            }
            if isMenuExpanded {
                menuOverlay
            }
        }
        .onAppear {
            ensureProfileExists()
        }
    }
    
    // MARK: - Freeze Row
    private var freezeRow: some View {
        HStack(spacing: 8) {
            ForEach(0..<8) { index in
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .offset(heartOffsets[index])
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                heartOffsets[index] = value.translation
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                    heartOffsets[index] = .zero
                                }
                            }
                    )
            }
            Spacer()
        }
    }
    
    // MARK: - Aura Element (Deprecated/Moved to SwordHeroCard)
    // Removing old heroSection and auraElement entirely as requested to clean the middle.
    
    // MARK: - Targets Section
    private var targetsSection: some View {
        HStack(spacing: 12) {
            ForEach(mockTargets) { target in
                VStack(alignment: .leading, spacing: 8) {
                    Text(target.name.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .tracking(1)
                    
                    if target.current >= target.goal {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(target.color)
                            Text("DONE")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.kaizenWhite)
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(target.current)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.kaizenWhite)
                            Text("/\(target.goal)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.kaizenGray)
                        }
                    }
                    
                    // Simple progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.kaizenGray.opacity(0.2))
                            Capsule()
                                .fill(target.color)
                                .frame(width: geo.size.width * min(1.0, CGFloat(target.current) / CGFloat(target.goal)))
                        }
                    }
                    .frame(height: 4)
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(Color.kaizenShadow.opacity(0.4))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kaizenGray.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, UIConstants.Spacing.lg)
    }
    
    // MARK: - Bottom Nav Bar
    private var bottomNavBar: some View {
        HStack {
            Button(action: { path.append(.improvement) }) {
                Text("Improvement")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
            }
            
            Spacer()
            
            // Central Plus Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isMenuExpanded.toggle()
                    HapticManager.shared.playWorkoutStart()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.kaizenSage)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.kaizenSage.opacity(0.4), radius: 15, x: 0, y: 0) // Core Glow
                        .shadow(color: Color.kaizenSage.opacity(0.2), radius: 30, x: 0, y: 0) // Outer Glow
                    
                    Image(systemName: "plus")
                        .font(.title.weight(.bold))
                        .foregroundColor(.kaizenShadow)
                        .rotationEffect(.degrees(isMenuExpanded ? 45 : 0))
                }
            }
            .offset(y: -20)
            
            Spacer()
            
            Button(action: { path.append(.calendar(profile?.currentSwordTier.rawValue ?? "Wooden")) }) {
                Text("Calendar")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, UIConstants.Spacing.lg)
    }
    
    // MARK: - Expanding Menu Overlay
    private var menuOverlay: some View {
        ZStack {
            // Blurred Background - Tapping anywhere dismisses
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    closeMenu()
                }
            
            VStack(spacing: 20) {
                Spacer()
                
                // Exercise Options - Staggered "Pop"
                if isMenuExpanded {
                    VStack(spacing: 16) {
                        menuItem(title: "Pushups", pr: "45 PR", icon: "figure.pushups", delay: 0.1) {
                            closeMenu()
                            path.append(.workoutSetup(.pushups))
                        }
                        
                        menuItem(title: "Squats", pr: "80 PR", icon: "figure.cross.training", delay: 0.05) {
                            closeMenu()
                            path.append(.workoutSetup(.squats))
                        }
                        
                        menuItem(title: "Plank", pr: "2:00 PR", icon: "figure.strengthtraining.functional", delay: 0.0) {
                            closeMenu()
                            path.append(.workoutSetup(.plank))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Close / Large Plus Button
                Button(action: {
                    closeMenu()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.kaizenWhite)
                            .frame(width: 70, height: 70)
                        
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
            .background(
                Capsule()
                    .fill(Color.kaizenShadow.opacity(0.9))
            )
        }
        .scaleEffect(isMenuExpanded ? 1.0 : 0.8)
        .opacity(isMenuExpanded ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay), value: isMenuExpanded)
    }
    
    // MARK: - Helper Methods
    private func closeMenu() {
        HapticManager.shared.playWorkoutStart()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isMenuExpanded = false
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
}

// Supporting Models for Preview/Mock
struct ExerciseTarget: Identifiable {
    let id = UUID()
    let name: String
    let current: Int
    let goal: Int
    let color: Color
}

// Helper for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
