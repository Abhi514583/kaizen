import SwiftUI

struct CalendarView: View {
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            VStack {
                Text("Calendar")
                    .font(.kaizenLargeHeader)
                    .foregroundColor(.kaizenWhite)
                Text("History & Habits")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
            }
        }
    }
}
