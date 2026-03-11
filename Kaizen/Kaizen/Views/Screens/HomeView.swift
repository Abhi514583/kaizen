import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \ExerciseSession.date, order: .reverse) private var sessions: [ExerciseSession]
    
    @Binding var path: [KaizenRoute]
    
    @State private var isMenuExpanded = false
    @State private var auraOffset = CGSize.zero
    @State private var showCalendarPanel = false
    @State private var heartOffsets: [CGSize] = Array(repeating: .zero, count: 8)
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    // Mock data for Sprint 1
    private let mockStreak = 10
    private let weekday = Date().formatted(.dateTime.weekday(.wide))

    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - App Branding
                Text("KAIZEN")
                    .font(.kaizenSectionHeader)
                    .fontWeight(.bold)
                    .foregroundColor(.kaizenWhite)
                    .tracking(4)
                    .padding(.top, 20)
                
                // MARK: - Header Section
                headerSection
                
                // MARK: - Freeze Row
                freezeRow
                
                Spacer()
                
                // MARK: - Floating Aura Element
                auraElement
                
                Spacer()
                
                // MARK: - Bottom Navigation
                bottomNavBar
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.height > 100 {
                            withAnimation(.spring()) {
                                showCalendarPanel = true
                            }
                        }
                    }
            )
            
            // MARK: - Calendar Panel Overlay
            if showCalendarPanel {
                calendarPanelOverlay
            }
            
            // MARK: - Expanding Menu Overlay
            if isMenuExpanded {
                menuOverlay
            }
        }
        .onAppear {
            ensureProfileExists()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            // Streak count on the left
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(mockStreak)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.kaizenWhite)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 14, height: 14)
                    .offset(y: -10)
            }
            
            Spacer()
            
            // Weekday on the right - Clickable to open Calendar
            Button(action: {
                withAnimation(.spring()) {
                    showCalendarPanel = true
                }
            }) {
                Text(weekday)
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.kaizenShadow)
                    .cornerRadius(8)
            }
            .offset(y: -15)
        }
        .padding(.horizontal, UIConstants.Spacing.lg)
        .padding(.top, 10)
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
        .padding(.horizontal, UIConstants.Spacing.lg)
        .padding(.top, 4)
    }
    
    // MARK: - Aura Element
    private var auraElement: some View {
        ZStack {
            // Subtle glow
            Circle()
                .fill(Color.kaizenSage.opacity(0.15))
                .frame(width: 120, height: 120)
                .blur(radius: 20)
            
            // The Orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.kaizenSage, .kaizenSage.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: .kaizenSage.opacity(0.3), radius: 15)
        }
        .offset(auraOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    auraOffset = value.translation
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        auraOffset = .zero
                    }
                }
        )
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
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.title.weight(.bold))
                        .foregroundColor(.kaizenShadow)
                        .rotationEffect(.degrees(isMenuExpanded ? 45 : 0))
                }
            }
            .offset(y: -20)
            
            Spacer()
            
            Button(action: { path.append(.calendar) }) {
                Text("Calendar")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, UIConstants.Spacing.lg)
    }
    
    // MARK: - Menu Overlay
    private var menuOverlay: some View {
        ZStack {
            Color.kaizenShadow.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isMenuExpanded = false }
                }
            
            VStack(spacing: 20) {
                workoutMenuButton(title: "Pushups", color: .kaizenSage)
                workoutMenuButton(title: "Squats", color: .kaizenWood)
                workoutMenuButton(title: "Plank", color: .kaizenGray)
            }
            .padding(.bottom, 150)
        }
    }
    
    private func workoutMenuButton(title: String, color: Color) -> some View {
        Button(action: {
            withAnimation {
                isMenuExpanded = false
                path.append(.workoutSetup)
            }
        }) {
            Text(title)
                .font(.kaizenSectionHeader)
                .foregroundColor(.kaizenShadow)
                .frame(width: 220, height: 64)
                .background(color)
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Calendar Panel Overlay
    private var calendarPanelOverlay: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.kaizenGray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
            
            CalendarView()
                .padding(.top, 20)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    showCalendarPanel = false
                }
            }) {
                Text("Close")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
                    .padding(.bottom, 30)
            }
        }
        .background(Color.kaizenShadow)
        .cornerRadius(32, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.3), radius: 20)
        .padding(.top, 100)
        .transition(.move(edge: .bottom))
        .zIndex(10)
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
