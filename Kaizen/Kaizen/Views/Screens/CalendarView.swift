import SwiftUI

enum RitualStatus {
    case completed, rest, empty
}

extension Date: Identifiable {
    public var id: String { self.description }
}

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let ritualStatus: RitualStatus
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .black : .bold))
                    .foregroundColor(isToday ? .kaizenSage : (ritualStatus == .empty ? .kaizenGray.opacity(0.5) : .kaizenWhite))
                
                Circle()
                    .fill(statusColor)
                    .frame(width: 4, height: 4)
                    .shadow(color: statusColor.opacity(0.8), radius: 2)
                    .opacity(ritualStatus == .empty ? 0 : 1)
            }
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isToday ? Color.kaizenSage.opacity(0.1) : Color.clear)
            )
        }
    }
    
    private var statusColor: Color {
        switch ritualStatus {
        case .completed: return .kaizenSage
        case .rest: return .kaizenGray
        case .empty: return .clear
        }
    }
}

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date? = nil
    @State private var viewMode: ViewMode = .monthly
    
    enum ViewMode {
        case monthly, yearly
    }
    
    // Mock Data for Ritual Consistency
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter
    }()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        ZStack {
            // MARK: - Immersive Background
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewMode == .monthly ? monthFormatter.string(from: Date()).uppercased() : "2024 LEGACY")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.kaizenWhite)
                            .tracking(2)
                        
                        Text("CONSISTENCY TRACKER")
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
                
                // View Switcher
                HStack(spacing: 0) {
                    switcherButton(title: "MONTHLY", mode: .monthly)
                    switcherButton(title: "YEARLY", mode: .yearly)
                }
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 24)
                
                ScrollView(showsIndicators: false) {
                    if viewMode == .monthly {
                        monthlyGridView
                    } else {
                        YearlyHabitTracker(year: 2024)
                            .padding(.horizontal, 24)
                    }
                    
                    // MARK: - Stats HUD
                    HStack(spacing: 20) {
                        miniStat(title: "TOTAL SESSIONS", value: "24", icon: "flame.fill", color: .kaizenSage)
                        miniStat(title: "FREEZES USED", value: "2/8", icon: "heart.fill", color: .red)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                }
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
                .presentationDetents([.height(450)])
                .presentationDragIndicator(.visible)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var monthlyGridView: some View {
        VStack(spacing: 20) {
            // Weekday Labels
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isCurrentMonth: true,
                            isToday: calendar.isDateInToday(date),
                            ritualStatus: getRitualStatus(for: date)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 45)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func switcherButton(title: String, mode: ViewMode) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) { viewMode = mode }
            HapticManager.shared.playWorkoutStart()
        }) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(viewMode == mode ? .kaizenWhite : .kaizenGray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(viewMode == mode ? Color.kaizenGray.opacity(0.1) : Color.clear)
        }
    }
    
    // MARK: - Logic
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else { return [] }
        
        let days = calendar.range(of: .day, in: .month, for: Date())!.count
        var dates: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...days {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func getRitualStatus(for date: Date) -> RitualStatus {
        let day = calendar.component(.day, from: date)
        if day == 7 || day == 13 { return .rest } // Using rest color for freeze/broken in monthly for now
        if day % 2 == 0 { return .completed }
        return .empty
    }
    
    private func miniStat(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.kaizenGray)
                Text(value)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.kaizenWhite)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.kaizenShadow.opacity(0.5))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.kaizenGray.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Components REFINED
struct DayDetailView: View {
    let date: Date
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(date.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.kaizenWhite)
                        Text("RITUAL MANIFEST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenSage)
                            .tracking(3)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.kaizenSage.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .blur(radius: 5)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.kaizenSage)
                    }
                }
                
                // Enhanced Stats List
                VStack(spacing: 16) {
                    historyRow(title: "PUSHUPS", value: "45", isMax: true, icon: "figure.pushups")
                    historyRow(title: "SQUATS", value: "60", isMax: false, icon: "figure.squats")
                    historyRow(title: "PLANK", value: "1:30", isMax: false, icon: "figure.plank")
                }
                
                // Summary Footer
                VStack(alignment: .leading, spacing: 8) {
                    Text("TOTAL VOLUME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenGray)
                    Text("105 ACTIONS • 04:20 MINS")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.kaizenWhite)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(30)
        }
    }
    
    private func historyRow(title: String, value: String, isMax: Bool, icon: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isMax ? .kaizenSage : .kaizenGray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.kaizenWhite)
                if isMax {
                    Text("NEW PERSONAL BEST")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.kaizenSage)
                }
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(isMax ? .kaizenSage : .kaizenWhite)
        }
        .padding(18)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isMax ? Color.kaizenSage.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    CalendarView()
}
