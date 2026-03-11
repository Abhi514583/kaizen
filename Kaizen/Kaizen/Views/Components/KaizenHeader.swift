import SwiftUI

struct KaizenHeader: View {
    let isHome: Bool
    var tier: String = "Wooden"
    var aura: String = "Muted"
    var onBack: (() -> Void)? = nil
    var onSettingsTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Slot: KAIZEN Branding
            if isHome {
                brandSection
            } else {
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    onBack?()
                }) {
                    Text("KAIZEN")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.kaizenWhite)
                        .tracking(3)
                        .contentShape(Rectangle())
                }
            }
            
            Spacer()
            
            // Middle Slot: Sword Artwork (Home Only)
            if isHome {
                swordArtwork
                Spacer()
            }
            
            // Right Slot: Settings Gear (Home Only)
            if isHome {
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    onSettingsTap?()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.kaizenGray.opacity(0.6))
                }
            } else {
                // Empty right slot to balance the center if needed, or just let spacer handle it
                // For "Inside" screens, we want KAIZEN to be the only thing or aligned left.
                // We'll leave it empty to keep KAIZEN on the far left.
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, isHome ? 16 : 10)
        .background(
            Group {
                if isHome {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.kaizenShadow.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.kaizenGray.opacity(0.05), lineWidth: 1)
                        )
                }
            }
        )
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
            .foregroundColor(.kaizenGray.opacity(0.8))
        }
    }
    
    private var swordArtwork: some View {
        ZStack {
            Capsule()
                .fill(Color.kaizenSage.opacity(0.3))
                .frame(width: 80, height: 6)
                .blur(radius: 4)
            
            Capsule()
                .fill(Color.kaizenWhite.opacity(0.4))
                .frame(width: 70, height: 2)
            
            Rectangle()
                .fill(Color.kaizenWhite.opacity(0.6))
                .frame(width: 1.5, height: 10)
                .offset(x: -25)
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
