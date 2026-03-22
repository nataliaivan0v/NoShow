import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var phone = ""
    @State private var otpCode = ""
    @State private var countryCode = "+1"
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var email = ""
    @State private var gender = "Prefer not to say"
    @State private var preferredClassTypes: Set<ClassType> = []
    @State private var acceptedTerms = false
    @State private var step: SignUpStep = .phone
    @State private var showUnderageError = false

    let genderOptions = ["Female", "Male", "Non-binary", "Prefer not to say"]

    enum SignUpStep {
        case phone, otp, name, details, terms
    }

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 24) {
                // Back button for steps after phone
                if step != .phone {
                    HStack {
                        Button {
                            switch step {
                            case .otp: step = .phone
                            case .name: step = .otp
                            case .details: step = .name
                            case .terms: step = .details
                            default: break
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(Theme.body())
                            .foregroundColor(Theme.white)
                        }
                        Spacer()
                    }
                }

                Text(stepTitle)
                    .font(Theme.screenTitle())
                    .foregroundColor(Theme.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

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

                        TextField("Email address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                        PrimaryButton(title: "Continue") {
                            step = .details
                        }
                        .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                    }

                case .details:
                    VStack(alignment: .leading, spacing: 20) {
                        // Birthdate
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date of birth")
                                .font(Theme.caption())
                                .foregroundColor(Theme.white.opacity(0.8))

                            HStack {
                                DatePicker(
                                    "",
                                    selection: $birthDate,
                                    in: ...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(Theme.orange)
                                .onChange(of: birthDate) { _, _ in
                                    showUnderageError = !isAtLeast18
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Theme.white)
                            .cornerRadius(12)

                            if showUnderageError {
                                Text("You must be at least 18 years old to use No Show.")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.white)
                                    .padding(10)
                                    .background(Color.red.opacity(0.6))
                                    .cornerRadius(8)
                            } else {
                                Text("You must be 18 or older to use this app.")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.white.opacity(0.6))
                            }
                        }

                        // Gender picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(Theme.caption())
                                .foregroundColor(Theme.white.opacity(0.8))

                            FlowLayout(spacing: 8) {
                                ForEach(genderOptions, id: \.self) { option in
                                    Button {
                                        gender = option
                                    } label: {
                                        Text(option)
                                            .font(Theme.caption())
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(gender == option ? Theme.white : Theme.white.opacity(0.25))
                                            .foregroundColor(gender == option ? Theme.orange : Theme.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        // Preferred class types
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Favorite class types (pick up to 3)")
                                .font(Theme.caption())
                                .foregroundColor(Theme.white.opacity(0.8))

                            FlowLayout(spacing: 8) {
                                ForEach(ClassType.allCases) { type in
                                    Button {
                                        if preferredClassTypes.contains(type) {
                                            preferredClassTypes.remove(type)
                                        } else if preferredClassTypes.count < 3 {
                                            preferredClassTypes.insert(type)
                                        }
                                    } label: {
                                        Text(type.rawValue)
                                            .font(Theme.caption())
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(preferredClassTypes.contains(type) ? Theme.white : Theme.white.opacity(0.25))
                                            .foregroundColor(preferredClassTypes.contains(type) ? Theme.orange : Theme.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        PrimaryButton(title: "Continue") {
                            if isAtLeast18 {
                                step = .terms
                            } else {
                                showUnderageError = true
                            }
                        }
                        .disabled(!isAtLeast18)
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
                                    birthDate: birthDate,
                                    email: email,
                                    gender: gender,
                                    preferredClassTypes: Array(preferredClassTypes)
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
            .padding(.top, 20)
        }
        .navigationBarBackButtonHidden(true)
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

    var isAtLeast18: Bool {
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
}
