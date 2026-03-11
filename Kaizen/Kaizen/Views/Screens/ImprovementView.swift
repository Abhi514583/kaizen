import SwiftUI

struct ImprovementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appearanceFactor: Double = 0
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Top Navigation
                HStack {
                    Button(action: {
                        HapticManager.shared.playWorkoutStart()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.kaizenGray)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Title Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("1% BETTER EVERY DAY")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.kaizenGray.opacity(0.6))
                                .tracking(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                        // Consistency Summary (Hero Layout)
                        summaryModule
                        
                        // Exercise Performance Cards
                        VStack(spacing: 24) {
                            ProgressCard(
                                title: "Push-ups",
                                baseline: 12,
                                current: 35,
                                trend: [0.2, 0.35, 0.3, 0.5, 0.6, 0.85, 1.0],
                                icon: "figure.pushups",
                                animate: appearanceFactor
                            )
                            
                            ProgressCard(
                                title: "Squats",
                                baseline: 20,
                                current: 45,
                                trend: [0.1, 0.25, 0.4, 0.35, 0.55, 0.7, 0.9],
                                icon: "figure.cross.training",
                                animate: appearanceFactor
                            )
                            
                            ProgressCard(
                                title: "Plank",
                                baseline: 45,
                                current: 120,
                                trend: [0.3, 0.4, 0.35, 0.6, 0.5, 0.8, 1.0],
                                icon: "figure.strengthtraining.functional",
                                isTime: true,
                                animate: appearanceFactor
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackFix()) // Fix for swipe-to-go-back when nav bar hidden
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appearanceFactor = 1.0
            }
        }
        .onSwipeBack {
            HapticManager.shared.playWorkoutStart()
            dismiss()
        }
    }
    
    private var summaryModule: some View {
        HStack {
            summaryItem(number: "6 / 7", label: "Days Active")
            Spacer()
            Divider().background(Color.white.opacity(0.1)).frame(height: 40)
            Spacer()
            summaryItem(number: "10", label: "Day Streak")
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
    
    private func summaryItem(number: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.kaizenSage)
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
                .tracking(1)
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
    var animate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    HStack(spacing: 12) {
                        statLabel(label: "Baseline", value: "\(baseline)\(isTime ? "s" : "")")
                        statLabel(label: "Current", value: "\(current)\(isTime ? "s" : "")", isHero: true)
                    }
                }
                
                Spacer()
                
                let improvement = Int((Double(current - baseline) / Double(baseline)) * 100)
                Text("+\(improvement)%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kaizenSage.opacity(0.6))
                    .padding(.top, 4)
            }
            
            // Sparkline with Baseline Indicator
            ZStack(alignment: .leading) {
                // Baseline marker
                Circle()
                    .fill(Color.kaizenSage.opacity(0.4))
                    .frame(width: 4, height: 4)
                    .offset(y: 20 - (CGFloat(trend[0]) * 40)) // Centered on first data point
                
                Sparkline(data: trend, completion: animate)
                    .stroke(Color.kaizenSage, lineWidth: 2)
                    .frame(height: 40)
                    .background(
                        Sparkline(data: trend, completion: animate)
                            .stroke(Color.kaizenSage.opacity(0.2), lineWidth: 4)
                            .blur(radius: 4)
                    )
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
    }
    
    private func statLabel(label: String, value: String, isHero: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.kaizenGray)
            Text(value)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(isHero ? .kaizenSage : .white)
        }
    }
}

struct Sparkline: Shape {
    let data: [Double]
    var completion: Double
    
    var animatableData: Double {
        get { completion }
        set { completion = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        let step = rect.width / CGFloat(data.count - 1)
        var points: [CGPoint] = []
        
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * step
            let y = rect.height - (CGFloat(value) * rect.height)
            points.append(CGPoint(x: x, y: y))
        }
        
        // Animated path
        path.move(to: points[0])
        let totalPoints = Int(Double(points.count - 1) * completion)
        
        if totalPoints >= 1 {
            for i in 1...totalPoints {
                path.addLine(to: points[i])
            }
            
            // Draw the partial segment
            if totalPoints < points.count - 1 {
                let remainder = (Double(points.count - 1) * completion).truncatingRemainder(dividingBy: 1)
                let p1 = points[totalPoints]
                let p2 = points[totalPoints + 1]
                let dx = p2.x - p1.x
                let dy = p2.y - p1.y
                path.addLine(to: CGPoint(x: p1.x + dx * CGFloat(remainder), y: p1.y + dy * CGFloat(remainder)))
            }
        }
        
        return path
    }
}

#Preview {
    NavigationStack {
        ImprovementView()
    }
}
