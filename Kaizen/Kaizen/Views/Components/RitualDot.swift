import SwiftUI

enum RitualDotStatus {
    case notStarted
    case inProgress
    case completed
}

struct RitualDot: View {
    let status: RitualDotStatus
    @State private var flickerOpacity: Double = 0.6
    
    var body: some View {
        Circle()
            .fill(dotColor)
            .frame(width: 12, height: 12)
            .opacity(status == .inProgress ? flickerOpacity : 1.0)
            .overlay(
                Circle()
                    .stroke(dotColor.opacity(0.3), lineWidth: 4)
                    .scaleEffect(status == .inProgress ? 1.5 : 1.0)
                    .opacity(status == .inProgress ? (1.0 - flickerOpacity) : 0.0)
            )
            .onAppear {
                if status == .inProgress {
                    startFlicker()
                }
            }
            .onChange(of: status) { _, newStatus in
                if newStatus == .inProgress {
                    startFlicker()
                } else {
                    flickerOpacity = 1.0
                }
            }
    }
    
    private var dotColor: Color {
        switch status {
        case .notStarted:
            return .kaizenEmber
        case .inProgress:
            return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .completed:
            return .kaizenMint
        }
    }
    
    private func startFlicker() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            flickerOpacity = 0.3
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RitualDot(status: .notStarted)
        RitualDot(status: .inProgress)
        RitualDot(status: .completed)
    }
    .padding()
    .background(Color.black)
}
