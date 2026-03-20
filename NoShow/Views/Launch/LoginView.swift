import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var phone = ""
    @State private var otpCode = ""

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Welcome back")
                    .font(Theme.screenTitle())
                    .foregroundColor(Theme.white)

                if !authVM.awaitingOTP {
                    // Phone input
                    VStack(spacing: 16) {
                        TextField("Phone number", text: $phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: authVM.isLoading ? "Sending..." : "Send Code") {
                            Task { await authVM.sendOTP(phone: phone) }
                        }
                        .disabled(phone.isEmpty || authVM.isLoading)
                    }
                } else {
                    // OTP input
                    VStack(spacing: 16) {
                        TextField("Enter 6-digit code", text: $otpCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: authVM.isLoading ? "Verifying..." : "Verify") {
                            Task { await authVM.verifyOTP(code: otpCode) }
                        }
                        .disabled(otpCode.count < 6 || authVM.isLoading)
                    }
                }

                if let error = authVM.errorMessage {
                    Text(error)
                        .font(Theme.caption())
                        .foregroundColor(Theme.white)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
        }
        .navigationBarBackButtonHidden(false)
    }
}
