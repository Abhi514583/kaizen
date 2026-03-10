import SwiftUI

struct KaizenHeader: View {
    let dayText: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: UIConstants.Spacing.xs) {
            Text(dayText)
                .font(.kaizenLargeHeader)
                .foregroundColor(.kaizenWhite)
            
            Circle()
                .fill(Color.kaizenSage)
                .frame(width: 8, height: 8)
                .padding(.bottom, 12) // Aligns exactly with the baseline of the large text
            
            Spacer()
        }
        .padding(.horizontal, UIConstants.Spacing.md)
        .padding(.vertical, UIConstants.Spacing.sm)
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        KaizenHeader(dayText: "Fri")
    }
}
