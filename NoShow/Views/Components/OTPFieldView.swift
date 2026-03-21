import SwiftUI

struct OTPFieldView: View {
    @Binding var code: String
    let length: Int = 6

    @FocusState private var focusedIndex: Int?
    @State private var digits: [String] = Array(repeating: "", count: 6)

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<length, id: \.self) { index in
                TextField("", text: $digits[index])
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 48, height: 56)
                    .background(Theme.white)
                    .cornerRadius(12)
                    .focused($focusedIndex, equals: index)
                    .onChange(of: digits[index]) { _, newValue in
                        // Only allow single digit
                        let filtered = newValue.filter { $0.isNumber }

                        if filtered.count > 1 {
                            // User pasted or typed extra — take last character
                            digits[index] = String(filtered.last!)
                        } else {
                            digits[index] = filtered
                        }

                        // Update the combined code
                        code = digits.joined()

                        // Auto-advance to next box
                        if !digits[index].isEmpty && index < length - 1 {
                            focusedIndex = index + 1
                        }
                    }
            }
        }
        .onAppear {
            focusedIndex = 0
        }
    }
}
