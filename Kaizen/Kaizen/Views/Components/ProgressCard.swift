import SwiftUI

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
            headerRow
            sparklineSection
        }
        .padding(24)
        .background(cardBackground)
    }
    
    private var headerRow: some View {
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
    }
    
    private var sparklineSection: some View {
        ZStack(alignment: .leading) {
            // Baseline marker
            Circle()
                .fill(Color.kaizenSage.opacity(0.4))
                .frame(width: 4, height: 4)
                .offset(y: 20 - (CGFloat(trend[0]) * 40))
            
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
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
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
