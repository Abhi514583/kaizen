import SwiftUI
import SwiftData

struct ImprovementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ProgressManager.self) private var progressManager
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailySummary.date, order: .reverse) private var summaries: [DailySummary]
    @State private var appearanceFactor: Double = 0

    private var profile: UserProfile? {
        profiles.first
    }

    private var daysActiveLast7: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) else { return 0 }

        return summaries.filter { summary in
            let day = calendar.startOfDay(for: summary.date)
            return day >= sevenDaysAgo && day <= today && summary.sessionsCompleted > 0
        }.count
    }

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
        .overlay(alignment: .bottom) {
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
            }
            .buttonStyle(.kaizenSecondary)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }

    private var summaryModule: some View {
        HStack {
            Spacer()
            summaryItem(number: "\(daysActiveLast7) / 7", label: "Days Active")
            Spacer()
            Divider().background(Color.white.opacity(0.1)).frame(height: 40)
            Spacer()
            summaryItem(number: "\(profile?.currentStreak ?? 0)", label: "Day Streak")
            Spacer()
        }
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
            ForEach([ExerciseType.pushups, .squats, .plank], id: \.rawValue) { type in
                let snapshot = progressManager.progressSnapshot(for: type, profile: profile)
                ProgressCard(
                    title: snapshot.title,
                    baseline: snapshot.baseline,
                    current: snapshot.current,
                    trend: snapshot.trend,
                    icon: snapshot.icon,
                    isTime: snapshot.isTime,
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
