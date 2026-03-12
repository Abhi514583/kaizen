import SwiftUI

struct ImprovementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appearanceFactor: Double = 0
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                KaizenHeader(isHome: false, onBack: { dismiss() })
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        titleHeader
                        summaryModule
                        performanceCards
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
    
    // MARK: - Subviews
    private var titleHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("PROGRESS")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Circle()
                    .fill(Color.kaizenSage)
                    .frame(width: 8, height: 8)
                    .padding(.bottom, 12)
            }
            
            Text("1% BETTER EVERY DAY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.kaizenGray.opacity(0.6))
                .tracking(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    private var performanceCards: some View {
        VStack(spacing: 24) {
            ForEach(MockDataProvider.mockPerformance) { mock in
                ProgressCard(
                    title: mock.title,
                    baseline: mock.baseline,
                    current: mock.current,
                    trend: mock.trend,
                    icon: mock.icon,
                    isTime: mock.isTime,
                    animate: appearanceFactor
                )
            }
        }
    }
}



#Preview {
    NavigationStack {
        ImprovementView()
    }
}
