import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.buttonLabel())
                .foregroundColor(Theme.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.black)
                .cornerRadius(12)
        }
    }
}
