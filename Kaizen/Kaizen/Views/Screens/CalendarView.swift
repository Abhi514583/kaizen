import SwiftUI
import SwiftData

// MARK: - Models
enum RitualStatus: String, Codable {
    case success, freeze, missed, future, inProgress
}

struct SessionStats: Codable {
    var volume: Int
    var maxShot: Int
    var goal: Int
}

struct RitualDay: Identifiable, Codable {
    let id: UUID
    let date: Date
    let status: RitualStatus
    let stats: [String: SessionStats] // Key: "Pushups", "Squats", "Plank"
    let sessionsCompleted: Int
}

// MARK: - ViewModel / Mock Generator
class CalendarViewModel: ObservableObject {
    @Published var history: [RitualDay] = []
    @Published var activeMonth: Date = Date()
    
    private let calendar = Calendar.current
    
    init() {}
    
    func loadRealData(context: ModelContext) {
        let summaryDescriptor = FetchDescriptor<DailySummary>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let sessionDescriptor = FetchDescriptor<ExerciseSession>()
        
        do {
            let summaries = try context.fetch(summaryDescriptor)
            let allSessions = (try? context.fetch(sessionDescriptor)) ?? []
            
            var newHistory: [RitualDay] = []
            let today = calendar.startOfDay(for: Date())
            
            for summary in summaries {
                let startOfDay = calendar.startOfDay(for: summary.date)
                let daySessions = allSessions.filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
                
                let pushupSessions = daySessions.filter { $0.exerciseType == .pushups }
                let squatSessions = daySessions.filter { $0.exerciseType == .squats }
                let plankSessions = daySessions.filter { $0.exerciseType == .plank }
                
                let pushupMax = pushupSessions.map { $0.repsOrDuration }.max() ?? 0
                let squatMax = squatSessions.map { $0.repsOrDuration }.max() ?? 0
                let plankMax = plankSessions.map { $0.repsOrDuration }.max() ?? 0
                
                let status: RitualStatus
                if summary.freezeUsed {
                    status = .freeze
                } else if summary.sessionsCompleted > 0 {
                    status = .success
                } else if startOfDay < today {
                    status = .missed
                } else {
                    status = .inProgress
                }
                
                let stats: [String: SessionStats] = [
                    "Pushups": SessionStats(volume: summary.pushupsTotal, maxShot: pushupMax, goal: 0),
                    "Squats": SessionStats(volume: summary.squatsTotal, maxShot: squatMax, goal: 0),
                    "Plank": SessionStats(volume: summary.plankTotal, maxShot: plankMax, goal: 0)
                ]
                
                newHistory.append(RitualDay(id: UUID(), date: startOfDay, status: status, stats: stats, sessionsCompleted: summary.sessionsCompleted))
            }
            
            self.history = newHistory
            
        } catch {
            print("Failed to load Calendar data: \(error)")
        }
    }
    
    func getStatus(for date: Date) -> RitualStatus {
        let startOfDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        
        if startOfDay > today { return .future }
        
        if let existing = history.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return existing.status
        }
        
        if startOfDay == today { return .inProgress }
        return .missed
    }
    
    func getDayData(for date: Date) -> RitualDay? {
        let startOfDay = calendar.startOfDay(for: date)
        
        if let existing = history.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return existing
        }
        
        // Return a synthesized Empty Day for historical days that had no data logged
        let today = calendar.startOfDay(for: Date())
        if startOfDay <= today {
            let status = getStatus(for: startOfDay)
            return RitualDay(id: UUID(),
                             date: startOfDay,
                             status: status,
                             stats: [:],
                             sessionsCompleted: 0)
        }
        
        return nil
    }
}

// MARK: - Views
struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    let tier: String // "Wooden", "Silver", "Black", etc.
    @State private var viewMode: ViewMode = .monthly
    @State private var selectedDay: RitualDay? = nil
    
    enum ViewMode {
        case monthly, yearly
    }
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                KaizenHeader(isHome: false, onBack: { dismiss() })
                    .padding(.top, 10)
                
                // Header (Title)
                headerSection
                    .padding(.top, 10)
                
                // Toggle
                HStack(spacing: 0) {
                    toggleButton(title: "MONTHLY", mode: .monthly)
                    toggleButton(title: "YEARLY", mode: .yearly)
                }
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                ScrollView(showsIndicators: false) {
                    if viewMode == .monthly {
                        MonthlyGridView(vm: vm, tier: tier, selectedDay: $selectedDay)
                    } else {
                        YearlyHeatmapView(vm: vm, tier: tier)
                    }
                    
                    // Legend
                    legendSection
                        .padding(.top, 20)
                        .padding(.bottom, 100) // Space for bottom button
                }
            }
            
            // Bottom Back Button (One-Handed Ergonomics)
            VStack {
                Spacer()
                Button(action: { 
                    HapticManager.shared.playWorkoutStart()
                    dismiss() 
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        Text("BACK")
                            .font(.system(size: 12, weight: .black))
                            .tracking(2)
                    }
                    .foregroundColor(.kaizenWhite)
                    .frame(height: 50)
                    .padding(.horizontal, 30)
                    .background(Color.kaizenShadow.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.kaizenGray.opacity(0.2), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(item: $selectedDay) { ritualDay in
            RitualManifestSheet(ritualDay: ritualDay)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            vm.loadRealData(context: modelContext)
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(viewMode == .monthly ? "RITUALS" : "LEGACY")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.kaizenWhite)
                    
                    Circle()
                        .fill(Color.kaizenSage)
                        .frame(width: 6, height: 6)
                        .padding(.bottom, 8)
                }
                
                Text(viewMode == .monthly ? "CONSISTENCY IS POWER" : "THE PATH RECORDED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kaizenGray)
                    .tracking(4)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private func toggleButton(title: String, mode: ViewMode) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewMode = mode
                HapticManager.shared.playWorkoutStart()
            }
        }) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(viewMode == mode ? .white : .kaizenGray)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    ZStack {
                        if viewMode == mode {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                )
        }
        .padding(4)
    }
    
    private var legendSection: some View {
        HStack(spacing: 20) {
            legendItem(title: "SUCCESS", color: successColor)
            legendItem(title: "FREEZE", color: .red, systemImage: "heart.fill")
            legendItem(title: "MISSED", color: .black)
        }
    }
    
    private var successColor: Color {
        if tier.lowercased().contains("silver") { return .white }
        if tier.lowercased().contains("black") { return Color(red: 0.7, green: 0.9, blue: 1.0) } // Diamond
        return .kaizenSage // Gold/Wooden
    }
    
    private func legendItem(title: String, color: Color, systemImage: String? = nil) -> some View {
        HStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 12, height: 12)
                if let img = systemImage {
                    Image(systemName: img)
                        .font(.system(size: 6))
                        .foregroundColor(.white)
                }
            }
            Text(title)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.kaizenGray)
        }
    }
}

struct MonthlyGridView: View {
    @ObservedObject var vm: CalendarViewModel
    let tier: String
    @Binding var selectedDay: RitualDay?
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 15) {
            // Month Nav
            HStack {
                Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left") }
                Spacer()
                Text(vm.activeMonth.formatted(.dateTime.month(.wide).year()).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .tracking(2)
                Spacer()
                Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right") }
            }
            .foregroundColor(.kaizenGray)
            .padding(.horizontal, 40)
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, status: vm.getStatus(for: date), tier: tier) {
                            if let data = vm.getDayData(for: date) {
                                selectedDay = data
                            }
                        }
                    } else {
                        Color.clear.frame(height: 45)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            changeMonth(by: 1)
                        } else if value.translation.width > 50 {
                            changeMonth(by: -1)
                        }
                    }
            )
        }
        .padding(.horizontal, 24)
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: vm.activeMonth) {
            HapticManager.shared.playWorkoutStart()
            withAnimation { vm.activeMonth = newDate }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: vm.activeMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else { return [] }
        
        let days = calendar.range(of: .day, in: .month, for: vm.activeMonth)!.count
        var dates: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for d in 0..<days {
            if let date = calendar.date(byAdding: .day, value: d, to: monthInterval.start) {
                dates.append(date)
            }
        }
        return dates
    }
}

struct DayCell: View {
    let date: Date
    let status: RitualStatus
    let tier: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(status == .success ? successColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                
                VStack(spacing: 2) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(status == .future ? .kaizenGray.opacity(0.3) : .white)
                    
                    if status == .freeze {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .disabled(status == .future)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .success: return successColor.opacity(0.8)
        case .freeze: return .red.opacity(0.8)
        case .missed: return .black
        case .future: return Color.kaizenGray.opacity(0.05)
        case .inProgress: return Color.orange.opacity(0.8)
        }
    }
    
    private var successColor: Color {
        if tier.lowercased().contains("silver") { return .white }
        if tier.lowercased().contains("black") { return Color(red: 0.7, green: 0.9, blue: 1.0) } // Diamond
        return .kaizenSage // Gold/Wooden
    }
}

struct YearlyHeatmapView: View {
    @ObservedObject var vm: CalendarViewModel
    let tier: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(0..<12) { m in
                    VStack(alignment: .center, spacing: 6) {
                        Text(monthName(m))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.kaizenGray)
                            .tracking(1)
                        
                        VStack(spacing: 3) {
                            ForEach(1...31, id: \.self) { d in
                                if let date = dateFor(month: m + 1, day: d) {
                                    HabitCell(status: vm.getStatus(for: date), tier: tier)
                                } else {
                                    Color.clear.frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 10)
    }
    
    private func monthName(_ m: Int) -> String {
        let fmt = DateFormatter()
        return fmt.shortMonthSymbols[m].uppercased()
    }
    
    private func dateFor(month: Int, day: Int) -> Date? {
        var comps = DateComponents()
        let calendar = Calendar.current
        comps.year = calendar.component(.year, from: Date())
        comps.month = month
        comps.day = day
        guard comps.isValidDate(in: calendar) else { return nil }
        return calendar.date(from: comps)
    }
}

struct HabitCell: View {
    let status: RitualStatus
    let tier: String
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 10, height: 10)
    }
    private var color: Color {
        switch status {
        case .success: return successColor
        case .freeze: return .red
        case .missed: return .black
        case .future: return Color.white.opacity(0.05)
        case .inProgress: return Color.orange
        }
    }
    
    private var successColor: Color {
        if tier.lowercased().contains("silver") { return .white }
        if tier.lowercased().contains("black") { return Color(red: 0.7, green: 0.9, blue: 1.0) } // Diamond
        return .kaizenSage // Gold/Wooden
    }
}

// MARK: - Ritual Manifest Sheet
struct RitualManifestSheet: View {
    let ritualDay: RitualDay
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ritualDay.date.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        Text("RITUAL MANIFEST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenSage)
                            .tracking(3)
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        statusPill
                        
                        if ritualDay.sessionsCompleted > 0 {
                            Text("\(ritualDay.sessionsCompleted) SESSIONS")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.kaizenGray)
                        }
                    }
                }
                
                if ritualDay.sessionsCompleted > 0 {
                    VStack(spacing: 16) {
                        exerciseRow(title: "PUSHUPS", stats: ritualDay.stats["Pushups"], icon: "figure.pushups")
                        exerciseRow(title: "SQUATS", stats: ritualDay.stats["Squats"], icon: "figure.cross.training")
                        exerciseRow(title: "PLANK", stats: ritualDay.stats["Plank"], icon: "figure.strengthtraining.functional", isTime: true)
                    }
                } else {
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.kaizenGray.opacity(0.3))
                        
                        Text(ritualDay.status == .future ? "THE FUTURE AWAITS" : "REST AND RECOVERY")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.kaizenGray)
                            .tracking(2)
                        
                        Text("No training activity recorded for this date.")
                            .font(.system(size: 12))
                            .foregroundColor(.kaizenGray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .padding(30)
        }
    }
    
    private var statusPill: some View {
        let status = ritualDay.status
        return Text(status.rawValue.uppercased())
            .font(.system(size: 10, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Group {
                    if status == .success { Color.kaizenSage }
                    else if status == .freeze { Color.red }
                    else if status == .inProgress { Color.orange }
                    else { Color.black }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(20)
    }
    
    private func exerciseRow(title: String, stats: SessionStats?, icon: String, isTime: Bool = false) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.kaizenGray)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(stats != nil ? (isTime ? "\(stats!.maxShot)s" : "\(stats!.maxShot)") : "--")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.kaizenSage)
                    Text("1-SHOT MAX")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.kaizenGray)
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                Text("TOTAL VOLUME")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.kaizenGray)
                Spacer()
                Text(stats != nil ? (isTime ? "\(stats!.volume)s" : "\(stats!.volume)") : "--")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CalendarView(tier: "Wooden")
}
