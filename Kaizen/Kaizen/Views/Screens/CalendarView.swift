import SwiftUI

// MARK: - Models
enum RitualStatus: String, Codable {
    case success, freeze, missed, future
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
}

// MARK: - ViewModel / Mock Generator
class CalendarViewModel: ObservableObject {
    @Published var history: [RitualDay] = []
    @Published var activeMonth: Date = Date()
    
    private let calendar = Calendar.current
    
    init() {
        generateMockHistory()
    }
    
    func generateMockHistory() {
        var mockDays: [RitualDay] = []
        let today = calendar.startOfDay(for: Date())
        
        for i in 0..<60 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let status: RitualStatus
                if i == 0 { status = .future }
                else if i % 15 == 0 { status = .missed }
                else if i % 7 == 0 { status = .freeze }
                else { status = .success }
                
                let stats: [String: SessionStats] = [
                    "Pushups": SessionStats(volume: 50 + Int.random(in: -10...20), maxShot: 35 + Int.random(in: -5...10), goal: 50),
                    "Squats": SessionStats(volume: 60 + Int.random(in: -5...15), maxShot: 40 + Int.random(in: -5...10), goal: 60),
                    "Plank": SessionStats(volume: 120 + Int.random(in: -20...40), maxShot: 90 + Int.random(in: -10...30), goal: 120)
                ]
                
                mockDays.append(RitualDay(id: UUID(), date: date, status: status, stats: stats))
            }
        }
        self.history = mockDays.reversed()
    }
    
    func getStatus(for date: Date) -> RitualStatus {
        if date > calendar.startOfDay(for: Date()) { return .future }
        return history.first(where: { calendar.isDate($0.date, inSameDayAs: date) })?.status ?? .future
    }
    
    func getDayData(for date: Date) -> RitualDay? {
        history.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
    }
}

// MARK: - Views
struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var viewMode: ViewMode = .monthly
    @State private var selectedDay: RitualDay? = nil
    
    enum ViewMode {
        case monthly, yearly
    }
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerSection
                
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
                        MonthlyGridView(vm: vm, selectedDay: $selectedDay)
                    } else {
                        YearlyHeatmapView(vm: vm)
                    }
                    
                    // Legend
                    legendSection
                        .padding(.top, 20)
                }
            }
        }
        .sheet(item: $selectedDay) { ritualDay in
            RitualManifestSheet(ritualDay: ritualDay)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewMode == .monthly ? "RITUAL CALENDAR" : "LEGACY HEATMAP")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.kaizenWhite)
                Text("CONSISTENCY IS POWER")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kaizenGray)
                    .tracking(4)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.kaizenGray.opacity(0.3))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private func toggleButton(title: String, mode: ViewMode) -> some View {
        Button(action: {
            withAnimation(.spring()) { viewMode = mode }
            HapticManager.shared.playWorkoutStart()
        }) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(viewMode == mode ? .white : .kaizenGray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewMode == mode ? Color.kaizenGray.opacity(0.2) : Color.clear)
        }
    }
    
    private var legendSection: some View {
        HStack(spacing: 20) {
            legendItem(title: "SUCCESS", color: .kaizenSage)
            legendItem(title: "FREEZE", color: .red, systemImage: "heart.fill")
            legendItem(title: "MISSED", color: .black)
        }
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
                        DayCell(date: date, status: vm.getStatus(for: date)) {
                            if let data = vm.getDayData(for: date) {
                                selectedDay = data
                            }
                        }
                    } else {
                        Color.clear.frame(height: 45)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: vm.activeMonth) {
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(status == .success ? Color.kaizenSage.opacity(0.3) : Color.clear, lineWidth: 1)
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
        case .success: return Color.kaizenSage.opacity(0.8) // Gold-equivalent in our palette
        case .freeze: return .red.opacity(0.8)
        case .missed: return .black
        case .future: return Color.kaizenGray.opacity(0.05)
        }
    }
}

struct YearlyHeatmapView: View {
    @ObservedObject var vm: CalendarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                ForEach(0..<12) { m in
                    VStack(spacing: 2) {
                        ForEach(1...31, id: \.self) { d in
                            if let date = dateFor(month: m + 1, day: d) {
                                HabitCell(status: vm.getStatus(for: date))
                            } else {
                                Color.clear.frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func dateFor(month: Int, day: Int) -> Date? {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps)
    }
}

struct HabitCell: View {
    let status: RitualStatus
    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(color)
            .frame(width: 10, height: 10)
    }
    private var color: Color {
        switch status {
        case .success: return .kaizenSage
        case .freeze: return .red
        case .missed: return .black
        case .future: return Color.white.opacity(0.05)
        }
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
                    statusPill
                }
                
                VStack(spacing: 16) {
                    exerciseRow(title: "PUSHUPS", stats: ritualDay.stats["Pushups"], icon: "figure.pushups")
                    exerciseRow(title: "SQUATS", stats: ritualDay.stats["Squats"], icon: "figure.cross.training")
                    exerciseRow(title: "PLANK", stats: ritualDay.stats["Plank"], icon: "figure.strengthtraining.functional", isTime: true)
                }
                
                Spacer()
            }
            .padding(30)
        }
    }
    
    private var statusPill: some View {
        Text(ritualDay.status.rawValue.uppercased())
            .font(.system(size: 10, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(ritualDay.status == .success ? Color.kaizenSage : (ritualDay.status == .freeze ? Color.red : Color.black))
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
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    CalendarView()
}
