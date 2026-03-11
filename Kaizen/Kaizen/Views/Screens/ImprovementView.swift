import SwiftUI

struct ImprovementView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("1% BETTER EVERY DAY")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.kaizenWhite)
                    Text("PERFORMANCE DASHBOARD")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .tracking(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Consistency Summary
                        summaryModule
                        
                        // Exercise Sections
                        ProgressCard(
                            title: "PUSH-UPS",
                            baseline: 12,
                            current: 35,
                            trend: [0.2, 0.35, 0.3, 0.5, 0.6, 0.85, 1.0],
                            icon: "figure.pushups"
                        )
                        
                        ProgressCard(
                            title: "SQUATS",
                            baseline: 20,
                            current: 45,
                            trend: [0.1, 0.25, 0.4, 0.35, 0.55, 0.7, 0.9],
                            icon: "figure.cross.training"
                        )
                        
                        ProgressCard(
                            title: "PLANK",
                            baseline: 45,
                            current: 120,
                            trend: [0.3, 0.4, 0.35, 0.6, 0.5, 0.8, 1.0],
                            icon: "figure.strengthtraining.functional",
                            isTime: true
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Space for bottom button
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
    }
    
    private var summaryModule: some View {
        HStack(spacing: 20) {
            summaryItem(label: "ADHERENCE", value: "6/7 DAYS")
            Divider().background(Color.white.opacity(0.1)).frame(height: 30)
            summaryItem(label: "STREAK", value: "10 DAYS")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
    
    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
                .tracking(2)
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.kaizenSage)
        }
    }
}

struct ProgressCard: View {
    let title: String
    let baseline: Int
    let current: Int
    let trend: [Double]
    let icon: String
    var isTime: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.kaizenGray)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(1)
                Spacer()
                
                HStack(spacing: 16) {
                    statBox(label: "BASELINE", value: "\(baseline)\(isTime ? "s" : "")")
                    statBox(label: "CURRENT", value: "\(current)\(isTime ? "s" : "")", highlight: true)
                }
            }
            
            // Sparkline
            Sparkline(data: trend)
                .stroke(Color.kaizenSage, lineWidth: 2)
                .frame(height: 40)
                .background(
                    Sparkline(data: trend)
                        .stroke(Color.kaizenSage.opacity(0.2), lineWidth: 4)
                        .blur(radius: 4)
                )
                .padding(.top, 8)
                
            HStack {
                Text("WEEKLY PERFORMANCE TREND")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.kaizenGray)
                Spacer()
                let improvement = Double(current - baseline) / Double(baseline) * 100
                Text("+\(Int(improvement))% IMPROVEMENT")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(.kaizenSage)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func statBox(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .foregroundColor(.kaizenGray)
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(highlight ? .kaizenSage : .white)
        }
    }
}

struct Sparkline: Shape {
    let data: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        let step = rect.width / CGFloat(data.count - 1)
        var x: CGFloat = 0
        
        for (index, value) in data.enumerated() {
            let y = rect.height - (CGFloat(value) * rect.height)
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            x += step
        }
        
        return path
    }
}

#Preview {
    ImprovementView()
}
