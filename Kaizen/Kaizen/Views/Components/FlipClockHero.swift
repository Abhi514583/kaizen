import SwiftUI

struct FlipClockHero: View {
    let value: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(digits, id: \.self) { digit in
                digitCard(for: digit)
            }
        }
    }
    
    private var digits: [Int] {
        String(format: "%01d", value).compactMap { Int(String($0)) }
    }
    
    private func digitCard(for digit: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
            
            Text("\(digit)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.kaizenCloud)
        }
        .frame(width: 58, height: 88)
        .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 12)
    }
}
