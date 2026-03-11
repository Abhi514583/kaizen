import SwiftUI

struct MasterHeaderCard: View {
    let tier: String
    let aura: String
    let weekday: String
    var onSettingsTap: () -> Void
    var onWeekdayTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Brand + Tier + Aura
            VStack(alignment: .leading, spacing: 2) {
                Text("KAIZEN")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.kaizenWhite)
                    .tracking(2)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(tier.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.kaizenSage)
                    Text("AURA: \(aura.uppercased())")
                        .font(.system(size: 7, weight: .medium))
                        .foregroundColor(.kaizenGray)
                }
            }
            
            Spacer()
            
            // Middle: Horizontal Sword Artwork
            ZStack {
                Capsule()
                    .fill(Color.kaizenSage.opacity(0.1))
                    .frame(width: 40, height: 4)
                    .blur(radius: 2)
                
                Capsule()
                    .fill(Color.kaizenWhite.opacity(0.2))
                    .frame(width: 30, height: 2)
                
                Rectangle()
                    .fill(Color.kaizenWhite.opacity(0.4))
                    .frame(width: 1, height: 8)
                    .offset(x: -10)
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            // Right: Settings + Weekday
            HStack(spacing: 12) {
                Button(action: onWeekdayTap) {
                    Text(weekday.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.kaizenShadow.opacity(0.5))
                        .cornerRadius(6)
                }
                
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.kaizenGray)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.kaizenShadow.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kaizenGray.opacity(0.1), lineWidth: 1)
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
            weekday: "Tuesday",
            onSettingsTap: {},
            onWeekdayTap: {}
        )
    }
}
