import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            VStack {
                Text("Settings")
                    .font(.kaizenLargeHeader)
                    .foregroundColor(.kaizenWhite)
                Text("App Configuration")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
            }
        }
    }
}
