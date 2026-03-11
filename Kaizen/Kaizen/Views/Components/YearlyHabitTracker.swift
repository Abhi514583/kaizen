import SwiftUI

struct YearlyHabitTracker: View {
    let year: Int
    
    // Mock Data for the Year
    // 12 months, each with daily statuses
    private let months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month Labels
            HStack(spacing: 0) {
                Text("    ") // Space for day numbers
                    .frame(width: 25)
                ForEach(months, id: \.self) { month in
                    Text(month)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 10)
            
            // The Grid
            HStack(alignment: .top, spacing: 0) {
                // Day Numbers (1-31)
                VStack(spacing: 4.5) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.kaizenGray.opacity(0.6))
                            .frame(height: 8)
                    }
                }
                .frame(width: 25)
                
                // Monthly Columns
                HStack(spacing: 2) {
                    ForEach(0..<12, id: \.self) { monthIndex in
                        VStack(spacing: 2) {
                            ForEach(1...31, id: \.self) { day in
                                if isValidDay(day, in: monthIndex + 1) {
                                    HabitCell(status: mockStatus(for: day, month: monthIndex + 1))
                                } else {
                                    Color.clear
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 10)
            
            // Legend
            HStack(spacing: 15) {
                legendItem(title: "CONSISTENT", color: .kaizenSage)
                legendItem(title: "FREEZE", color: .red)
                legendItem(title: "BROKEN", color: .black)
                legendItem(title: "PR HIT", color: .kaizenSage, hasAura: true)
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(Color.kaizenShadow.opacity(0.3))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.kaizenGray.opacity(0.1), lineWidth: 1))
    }
    
    // MARK: - Handlers & Mocking
    private func isValidDay(_ day: Int, in month: Int) -> Bool {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return components.isValidDate(in: calendar)
    }
    
    private func mockStatus(for day: Int, month: Int) -> HabitStatus {
        // Just some random distributions for the mock view
        let hash = (day * month) % 20
        if hash == 7 { return .freeze }
        if hash == 13 { return .broken }
        if hash % 5 == 0 { return .pr }
        if hash % 3 == 0 { return .consistent }
        return .none
    }
    
    private func legendItem(title: String, color: Color, hasAura: Bool = false) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.kaizenSage.opacity(0.5), lineWidth: hasAura ? 1 : 0)
                        .scaleEffect(2.0)
                        .opacity(hasAura ? 1 : 0)
                )
            Text(title)
                .font(.system(size: 6, weight: .black))
                .foregroundColor(.kaizenGray)
        }
    }
}

enum HabitStatus {
    case consistent, freeze, broken, pr, none
}

struct HabitCell: View {
    let status: HabitStatus
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(Color.kaizenSage, lineWidth: status == .pr ? 1 : 0)
                    .scaleEffect(1.5)
                    .blur(radius: 1)
                    .opacity(status == .pr ? 0.8 : 0)
            )
    }
    
    private var color: Color {
        switch status {
        case .consistent: return .kaizenSage
        case .freeze: return .red
        case .broken: return .black
        case .pr: return .kaizenSage
        case .none: return Color.kaizenGray.opacity(0.1)
        }
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        YearlyHabitTracker(year: 2024)
            .padding()
    }
}
