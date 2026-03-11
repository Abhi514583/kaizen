import SwiftUI

struct MasterHeaderCard: View {
    let tier: String
    let aura: String
    let weekday: String
    var onSettingsTap: () -> Void
    var onWeekdayTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Brand + Tiny Metadata
            VStack(alignment: .leading, spacing: 1) {
                Text("KAIZEN")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.kaizenWhite)
                    .tracking(2)
                
                HStack(spacing: 4) {
                    Text(tier.uppercased())
                    Text("•")
                        .font(.system(size: 6))
                    Text(aura.uppercased())
                }
                .font(.system(size: 7, weight: .bold))
                .foregroundColor(.kaizenGray.opacity(0.8))
            }
            
            Spacer()
            
            // Middle: Horizontal Sword Artwork
            ZStack {
                Capsule()
                    .fill(Color.kaizenSage.opacity(0.2))
                    .frame(width: 44, height: 4)
                    .blur(radius: 2)
                
                Capsule()
                    .fill(Color.kaizenWhite.opacity(0.3))
                    .frame(width: 34, height: 1.5)
                
                Rectangle()
                    .fill(Color.kaizenWhite.opacity(0.5))
                    .frame(width: 1, height: 6)
                    .offset(x: -12)
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            // Right: Settings + Weekday
            HStack(spacing: 12) {
                Button(action: onWeekdayTap) {
                    Text(weekday.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.kaizenShadow.opacity(0.3))
                        .cornerRadius(6)
                }
                
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.kaizenGray.opacity(0.6))
                }
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
            weekday: "Tuesday",
            onSettingsTap: {},
            onWeekdayTap: {}
        )
    }
}
