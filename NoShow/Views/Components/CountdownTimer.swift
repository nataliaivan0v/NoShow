import SwiftUI

struct CountdownTimer: View {
    let targetDate: Date
    @State private var timeRemaining: String = ""

    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(timeRemaining)
            .font(Theme.caption())
            .foregroundColor(Theme.orange)
            .onAppear { updateTime() }
            .onReceive(timer) { _ in updateTime() }
    }

    private func updateTime() {
        let diff = targetDate.timeIntervalSinceNow
        if diff <= 0 {
            timeRemaining = "Started"
        } else if diff < 3600 {
            timeRemaining = "Starts in \(Int(diff / 60))m"
        } else {
            let hours = Int(diff / 3600)
            let mins = Int((diff.truncatingRemainder(dividingBy: 3600)) / 60)
            timeRemaining = "Starts in \(hours)h \(mins)m"
        }
    }
}
