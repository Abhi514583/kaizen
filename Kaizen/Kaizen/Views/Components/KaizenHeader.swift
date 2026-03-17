import SwiftUI

struct KaizenHeader: View {
    let isHome: Bool
    var tier: String = "Wooden"
    var aura: String = "Muted"
    var onBack: (() -> Void)? = nil
    var onSettingsTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            if isHome {
                brandSection
            } else {
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    onBack?()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.kaizenFog)

                        Text("KAIZEN")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.kaizenWhite)
                            .tracking(3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .kaizenFloatingCapsule(tint: .white.opacity(0.1))
                    .contentShape(Rectangle())
                }
            }
            
            Spacer()
            
            if isHome {
                swordArtwork
                Spacer()
            }
            
            if isHome {
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    onSettingsTap?()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.kaizenCloud)
                        .frame(width: 48, height: 48)
                        .kaizenFloatingCapsule(tint: .white.opacity(0.08))
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, isHome ? 18 : 10)
        .kaizenGlassCard(cornerRadius: 28, tint: Color.white.opacity(isHome ? 0.07 : 0.04))
        .padding(.horizontal, UIConstants.Spacing.lg)
    }
    
    private var brandSection: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("KAIZEN")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.kaizenWhite)
                .tracking(3)
            
            HStack(spacing: 4) {
                Text(tier.uppercased())
                Text("•")
                    .font(.system(size: 6))
                Text(aura.uppercased())
            }
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(.kaizenFog.opacity(0.72))
        }
    }
    
    private var swordArtwork: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.kaizenMint.opacity(0.18), Color.white.opacity(0.02)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 112, height: 16)
                .blur(radius: 8)
            
            Capsule()
                .fill(Color.kaizenCloud.opacity(0.72))
                .frame(width: 90, height: 3)
            
            Rectangle()
                .fill(Color.kaizenCloud.opacity(0.65))
                .frame(width: 2, height: 16)
                .offset(x: -30)
        }
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        VStack(spacing: 20) {
            KaizenHeader(isHome: true, onSettingsTap: {})
            KaizenHeader(isHome: false, onBack: {})
        }
    }
}
