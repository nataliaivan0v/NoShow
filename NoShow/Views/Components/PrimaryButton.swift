import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.buttonLabel())
                .foregroundColor(Theme.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.white)
                .cornerRadius(12)
        }
    }
}
