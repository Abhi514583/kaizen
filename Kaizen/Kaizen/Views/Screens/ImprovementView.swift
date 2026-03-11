import SwiftUI

struct ImprovementView: View {
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            VStack {
                Text("1% Improvement")
                    .font(.kaizenLargeHeader)
                    .foregroundColor(.kaizenWhite)
                Text("Stats & Progression")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
            }
        }
    }
}
