import SwiftUI

struct SessionCompleteView: View {
    @Binding var path: [KaizenRoute]
    let exerciseType: ExerciseType
    let count: Int
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // MARK: - Immersive Background
            Color.kaizenShadow.ignoresSafeArea()
            
            // Subtle Ambient Glow
            Circle()
                .fill(Color.kaizenSage.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(y: -100)
            
            VStack(spacing: 30) {
                // MARK: - Share Card
                VStack(spacing: 0) {
                    // Card Header
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
                    
                    // Central Sword Visual
                    ZStack {
                        Circle()
                            .fill(Color.kaizenSage.opacity(0.1))
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                        
                        // Sword Asset Placeholder
                        VStack(spacing: 8) {
                            ZStack {
                                Capsule()
                                    .fill(Color.kaizenWhite.opacity(0.8))
                                    .frame(width: 4, height: 100)
                                    .shadow(color: Color.kaizenSage.opacity(0.5), radius: 10)
                                
                                Rectangle()
                                    .fill(Color.kaizenWhite)
                                    .frame(width: 30, height: 2)
                                    .offset(y: 20)
                            }
                            
                            Text("WOODEN TIER")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.kaizenSage)
                                .tracking(2)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Stats Section
                    VStack(spacing: 4) {
                        Text("\(count)")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.kaizenWhite)
                        
                        Text(exerciseType.rawValue.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.kaizenSage)
                            .tracking(6)
                    }
                    .padding(.bottom, 20)
                    
                    // Streak Integration
                    HStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("STREAK")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.kaizenGray)
                            Text("PRESERVED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.kaizenWhite)
                        }
                        
                        Spacer()
                        
                        // Small Flip Clock
                        FlipClockHero(value: 12) // Mock day
                            .scaleEffect(0.6)
                            .frame(width: 70, height: 50)
                    }
                    .padding(20)
                    .background(Color.kaizenShadow.opacity(0.5))
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.kaizenShadow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.kaizenSage.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 30)
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0)
                
                // MARK: - Action Floor
                if showContent {
                    VStack(spacing: 16) {
                        Button(action: {
                            HapticManager.shared.playSessionComplete()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("SHARE RESULT")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.kaizenShadow)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.kaizenWhite)
                            .cornerRadius(16)
                        }
                        
                        HStack(spacing: 12) {
                            secondaryButton(title: "SAVE VIDEO", icon: "video.fill")
                            secondaryButton(title: "DONE", icon: "checkmark") {
                                path = [] // Root
                            }
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
    
    private func secondaryButton(title: String, icon: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.kaizenWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.kaizenShadow)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.kaizenWhite.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    SessionCompleteView(path: .constant([]), exerciseType: .pushups, count: 25)
}
