import SwiftUI

struct SwordHeroCard: View {
    let tier: String
    let aura: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Stylized Horizontal Sword Placeholder
            ZStack {
                // Glow
                Capsule()
                    .fill(Color.kaizenSage.opacity(0.1))
                    .frame(width: 60, height: 8)
                    .blur(radius: 4)
                
                // Blade
                Capsule()
                    .fill(Color.kaizenWhite.opacity(0.2))
                    .frame(width: 40, height: 4)
                
                // Guard
                Rectangle()
                    .fill(Color.kaizenWhite.opacity(0.4))
                    .frame(width: 2, height: 12)
                    .offset(x: -15)
                
                // Hilt
                Capsule()
                    .fill(Color.kaizenWood.opacity(0.6))
                    .frame(width: 10, height: 3)
                    .offset(x: -20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                // Tier Label
                Text(tier.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kaizenWhite)
                    .tracking(2)
                
                // Aura State
                Text("AURA: \(aura.uppercased())")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.kaizenGray)
                    .tracking(1)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kaizenShadow.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kaizenGray.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        SwordHeroCard(tier: "Wooden", aura: "Muted")
    }
}
