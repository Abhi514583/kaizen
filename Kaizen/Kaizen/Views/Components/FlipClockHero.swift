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
            // Background card
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.kaizenShadow.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.kaizenGray.opacity(0.1), lineWidth: 1)
                )
            
            // The split line
            Rectangle()
                .fill(Color.kaizenGray.opacity(0.05))
                .frame(height: 1)
            
            // The digit
            Text("\(digit)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.kaizenWhite)
        }
        .frame(width: 70, height: 100)
    }
}
