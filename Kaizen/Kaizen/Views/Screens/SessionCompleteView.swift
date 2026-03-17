import SwiftUI
import SwiftData

struct SessionCompleteView: View {
    @Binding var path: [KaizenRoute]
    let exerciseType: ExerciseType
    let count: Int
    
    @Query private var profiles: [UserProfile]
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.kaizenShadow, Color(red: 0.12, green: 0.14, blue: 0.13)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.kaizenMint.opacity(0.14))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(y: -100)
            
            VStack(spacing: 30) {
                VStack(spacing: 0) {
                    HStack {
                        Text("KAIZEN")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.kaizenWhite)
                            .tracking(4)
                        Spacer()
                        Text(Date().formatted(.dateTime.day().month().year()))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenGray)
                    }
                    .padding(20)
                    
                    ZStack {
                        Circle()
                            .fill(Color.kaizenMint.opacity(0.14))
                            .frame(width: 180, height: 180)
                            .blur(radius: 30)
                        
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.regularMaterial)
                                    .frame(width: 92, height: 92)
                                    .overlay(
                                        Image(systemName: successIcon)
                                            .font(.system(size: 34, weight: .medium))
                                            .foregroundColor(.kaizenMint)
                                    )
                            }
                            
                            Text("WOODEN TIER")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.kaizenMint)
                                .tracking(2)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    VStack(spacing: 4) {
                        Text(exerciseType == .plank ? 
                             String(format: "%02d:%02d", count / 60, count % 60) : 
                             "\(count)")
                            .font(.system(size: exerciseType == .plank ? 64 : 72, weight: .black, design: .rounded))
                            .foregroundColor(.kaizenWhite)
                        
                        Text(exerciseType.rawValue.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.kaizenMint)
                            .tracking(6)
                    }
                    .padding(.bottom, 20)
                    
                    HStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("STREAK")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.kaizenFog.opacity(0.58))
                            Text((profiles.first?.currentStreak ?? 0) > 0 ? "PRESERVED" : "READY")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.kaizenWhite)
                        }
                        
                        Spacer()
                        
                        // Small Flip Clock
                        FlipClockHero(value: profiles.first?.currentStreak ?? 0)
                            .scaleEffect(0.6)
                            .frame(width: 70, height: 50)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.18))
                }
                .kaizenGlassCard(cornerRadius: 34, tint: Color.kaizenMint.opacity(0.08))
                .padding(.horizontal, 30)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0)
                
                if showContent {
                    VStack(spacing: 16) {
                        Button(action: {
                            HapticManager.shared.playWorkoutStart()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("SHARE RESULT")
                            }
                        }
                        .buttonStyle(.kaizenPrimary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                HapticManager.shared.playWorkoutStart()
                            }) {
                                HStack {
                                    Image(systemName: "video.fill")
                                    Text("SAVE VIDEO")
                                }
                            }
                            .buttonStyle(.kaizenSecondary)
                            
                            Button(action: {
                                path = [] // Root
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("DONE")
                                }
                            }
                            .buttonStyle(.kaizenSecondary)
                        }
                    }
                    .padding(.horizontal, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackFix())
        .onSwipeBack {
            path = [] // Back to home
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
                HapticManager.shared.playSessionComplete()
            }
        }
    }

    private var successIcon: String {
        switch exerciseType {
        case .pushups: return "figure.pushups"
        case .squats: return "figure.cross.training"
        case .plank: return "figure.strengthtraining.functional"
        }
    }
}

#Preview {
    SessionCompleteView(path: .constant([]), exerciseType: .pushups, count: 25)
}
