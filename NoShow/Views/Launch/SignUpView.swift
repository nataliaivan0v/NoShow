import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var phone = ""
    @State private var otpCode = ""
    @State private var firstName = ""
    @State private var step: SignUpStep = .phone
    @State private var acceptedTerms = false

    enum SignUpStep {
        case phone, otp, profile, terms
    }

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 24) {
                Text(stepTitle)
                    .font(Theme.screenTitle())
                    .foregroundColor(Theme.white)

                switch step {
                case .phone:
                    VStack(spacing: 16) {
                        TextField("Phone number", text: $phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: "Send Code") {
                            Task {
                                await authVM.sendOTP(phone: phone)
                                if authVM.awaitingOTP { step = .otp }
                            }
                        }
                        .disabled(phone.isEmpty)
                    }

                case .otp:
                    VStack(spacing: 16) {
                        TextField("Enter 6-digit code", text: $otpCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: "Verify") {
                            Task {
                                await authVM.verifyOTP(code: otpCode)
                                if authVM.isAuthenticated { step = .profile }
                            }
                        }
                        .disabled(otpCode.count < 6)
                    }

                case .profile:
                    VStack(spacing: 16) {
                        TextField("First name", text: $firstName)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: "Continue") {
                            step = .terms
                        }
                        .disabled(firstName.isEmpty)
                    }

                case .terms:
                    VStack(spacing: 16) {
                        Text("By using No Show, you acknowledge that credential sharing is at your own risk. You accept responsibility for any studio terms of service violations. No Show is a platform facilitator and assumes no liability.")
                            .font(Theme.caption())
                            .foregroundColor(Theme.white.opacity(0.9))
                            .multilineTextAlignment(.leading)

                        HStack {
                            Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(Theme.white)
                                .onTapGesture { acceptedTerms.toggle() }
                            Text("I accept the Terms of Service")
                                .font(Theme.body())
                                .foregroundColor(Theme.white)
                        }

                        PrimaryButton(title: "Get Started") {
                            Task {
                                await authVM.createProfile(firstName: firstName)
                            }
                        }
                        .disabled(!acceptedTerms)
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

    var stepTitle: String {
        switch step {
        case .phone: return "Create account"
        case .otp: return "Verify phone"
        case .profile: return "What's your name?"
        case .terms: return "One last thing"
        }
    }
}
