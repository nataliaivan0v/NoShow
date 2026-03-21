import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var phone = ""
    @State private var otpCode = ""
    @State private var countryCode = "+1"
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var gender = "Prefer not to say"
    @State private var neighborhood = ""
    @State private var acceptedTerms = false
    @State private var step: SignUpStep = .phone

    let genderOptions = ["Female", "Male", "Non-binary", "Prefer not to say"]

    enum SignUpStep {
        case phone, otp, name, details, terms
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
                        Text("Enter your phone number to get started")
                            .font(Theme.body())
                            .foregroundColor(Theme.white.opacity(0.85))

                        HStack(spacing: 10) {
                            TextField("+1", text: $countryCode)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Theme.white)
                                .cornerRadius(12)
                                .frame(width: 72)
                                .onChange(of: countryCode) { _, newValue in
                                    let digits = newValue.filter { $0.isNumber || $0 == "+" }
                                    if !digits.hasPrefix("+") {
                                        countryCode = "+" + digits.filter { $0.isNumber }
                                    } else {
                                        countryCode = digits
                                    }
                                    countryCode = String(countryCode.prefix(4))
                                }

                            TextField("(617) 555-0000", text: $phone)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Theme.white)
                                .cornerRadius(12)
                                .onChange(of: phone) { _, newValue in
                                    let digits = newValue.filter { $0.isNumber }
                                    let limited = String(digits.prefix(10))
                                    phone = formatPhoneNumber(limited)
                                }
                        }

                        PrimaryButton(title: "Send Code") {
                            Task {
                                let digits = phone.filter { $0.isNumber }
                                await authVM.sendOTP(phone: "\(countryCode)\(digits)")
                                if authVM.awaitingOTP { step = .otp }
                            }
                        }
                        .disabled(phone.filter({ $0.isNumber }).count < 10)
                    }

                case .otp:
                    VStack(spacing: 16) {
                        Text("Enter the 6-digit code we sent to \(phone)")
                            .font(Theme.body())
                            .foregroundColor(Theme.white.opacity(0.85))
                            .multilineTextAlignment(.center)

                        OTPFieldView(code: $otpCode)

                        PrimaryButton(title: "Verify") {
                            Task {
                                await authVM.verifyOTP(code: otpCode)
                                if authVM.isAuthenticated { step = .name }
                            }
                        }
                        .disabled(otpCode.count < 6)
                    }

                case .name:
                    VStack(spacing: 16) {
                        TextField("First name", text: $firstName)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        TextField("Last name", text: $lastName)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: "Continue") {
                            step = .details
                        }
                        .disabled(firstName.isEmpty || lastName.isEmpty)
                    }

                case .details:
                    VStack(spacing: 16) {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        // Gender picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gender")
                                .font(Theme.caption())
                                .foregroundColor(Theme.white.opacity(0.8))

                            HStack(spacing: 8) {
                                ForEach(genderOptions, id: \.self) { option in
                                    Button {
                                        gender = option
                                    } label: {
                                        Text(option)
                                            .font(Theme.caption())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(gender == option ? Theme.white : Theme.white.opacity(0.25))
                                            .foregroundColor(gender == option ? Theme.orange : Theme.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        TextField("Neighborhood (e.g. Back Bay, Williamsburg)", text: $neighborhood)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: "Continue") {
                            step = .terms
                        }
                        .disabled(age.isEmpty || neighborhood.isEmpty)
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
                                await authVM.createProfile(
                                    firstName: firstName,
                                    lastName: lastName,
                                    age: Int(age) ?? 0,
                                    gender: gender,
                                    neighborhood: neighborhood
                                )
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
        case .name: return "What's your name?"
        case .details: return "Tell us about you"
        case .terms: return "One last thing"
        }
    }

    // Formats "6175550000" → "(617) 555-0000"
    func formatPhoneNumber(_ digits: String) -> String {
        var result = ""
        let chars = Array(digits)
        for (i, c) in chars.enumerated() {
            if i == 0 { result += "(" }
            if i == 3 { result += ") " }
            if i == 6 { result += "-" }
            result.append(c)
        }
        return result
    }
}
