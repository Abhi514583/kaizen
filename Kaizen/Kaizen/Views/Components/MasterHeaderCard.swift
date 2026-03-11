import SwiftUI

struct MasterHeaderCard: View {
    let tier: String
    let aura: String
    var onSettingsTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Brand + Tiny Metadata
            VStack(alignment: .leading, spacing: 1) {
                Text("KAIZEN")
                    .font(.system(size: 20, weight: .bold)) // Bigger Brand
                    .foregroundColor(.kaizenWhite)
                    .tracking(3)
                
                HStack(spacing: 4) {
                    Text(tier.uppercased())
                    Text("•")
                        .font(.system(size: 6))
                    Text(aura.uppercased())
                }
                .font(.system(size: 8, weight: .bold)) // Slightly bigger meta
                .foregroundColor(.kaizenGray.opacity(0.8))
            }
            
            Spacer()
            
            // Middle: Horizontal Sword Artwork - SIGNIFICANTLY BIGGER
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
            .padding(.horizontal, 16)
            
            Spacer()
            
            // Right: Settings Only (Weekday removed)
            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.kaizenGray.opacity(0.6))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kaizenShadow.opacity(0.2)) // More transparent
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kaizenGray.opacity(0.05), lineWidth: 1)
                )
        )
        .padding(.horizontal, UIConstants.Spacing.lg)
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        MasterHeaderCard(
            tier: "Wooden",
            aura: "Muted",
            onSettingsTap: {}
        )
    }
}
