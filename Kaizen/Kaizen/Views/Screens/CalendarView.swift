import SwiftUI

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date? = nil
    
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
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(monthFormatter.string(from: Date()).uppercased())
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.kaizenWhite)
                            .tracking(2)
                        
                        Text("RITUAL HISTORY")
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
                
                // MARK: - Calendar Grid
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
                
                // MARK: - Stats HUD
                HStack(spacing: 20) {
                    miniStat(title: "TOTAL SESSIONS", value: "24", icon: "flame.fill", color: .kaizenSage)
                    miniStat(title: "STAY CONSISTENT", value: "85%", icon: "target", color: .kaizenWhite)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .sheet(item: $selectedDate) { date in
            DayDetailView(date: date)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .navigationBarBackButtonHidden(true)
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
        // Mocking some patterns: even days are workouts, multiples of 5 are rest
        if day % 5 == 0 { return .rest }
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

// MARK: - Helper Types
enum RitualStatus {
    case completed, rest, empty
}

extension Date: Identifiable {
    public var id: String { self.description }
}

// MARK: - Components
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

struct DayDetailView: View {
    let date: Date
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(date.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.kaizenWhite)
                        Text("RITUAL SUMMARY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenSage)
                    }
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.kaizenSage)
                }
                
                VStack(spacing: 12) {
                    historyRow(title: "Pushups", value: "35 Reps", icon: "figure.pushups")
                    historyRow(title: "Session Time", value: "08:45", icon: "clock.fill")
                }
                
                Spacer()
            }
            .padding(30)
        }
    }
    
    private func historyRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.kaizenGray)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.kaizenWhite)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.kaizenSage)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    CalendarView()
}
