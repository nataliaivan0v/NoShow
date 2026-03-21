import SwiftUI

struct CreateListingView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var studioName = ""
    @State private var className = ""
    @State private var classType: ClassType = .yoga
    @State private var classDate = Date()
    @State private var location = ""
    @State private var originalPrice = ""
    @State private var studioEmail = ""
    @State private var studioPassword = ""
    @State private var additionalNotes = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false

    private let listingService = ListingService()

    var askingPrice: Double {
        let price = Double(originalPrice) ?? 30.0
        return price * 0.5
    }

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                Text("List a Class")
                    .font(Theme.screenTitle())
                    .foregroundColor(Theme.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                // Form
                ScrollView {
                    VStack(spacing: 14) {
                        // Class info section
                        formSection("Class Info") {
                            formField("Studio name", text: $studioName)
                            formField("Class name", text: $className)

                            // Class type picker
                            HStack {
                                Text("Class type")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Picker("Type", selection: $classType) {
                                    ForEach(ClassType.allCases) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .tint(Theme.orange)
                            }
                            .padding(.horizontal, 16)

                            DatePicker("Date & Time", selection: $classDate, in: Date()...)
                                .padding(.horizontal, 16)
                                .tint(Theme.orange)

                            formField("Location / Address", text: $location)
                        }

                        // Pricing section
                        formSection("Pricing") {
                            formField("Original price ($)", text: $originalPrice, keyboard: .decimalPad)

                            HStack {
                                Text("Buyer pays")
                                    .font(Theme.body())
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Text("$\(String(format: "%.0f", askingPrice))")
                                    .font(Theme.sectionTitle())
                                    .foregroundColor(Theme.orange)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }

                        // Studio credentials section
                        formSection("Studio Login (encrypted)") {
                            formField("Studio account email", text: $studioEmail, keyboard: .emailAddress)
                            SecureField("Studio account password", text: $studioPassword)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                        }

                        // Notes section
                        formSection("Additional Info (optional)") {
                            TextField("Door code, studio #, parking, bring mat...", text: $additionalNotes, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                        }

                        // Submit
                        PrimaryButton(title: isSubmitting ? "Posting..." : "List This Spot") {
                            Task { await submitListing() }
                        }
                        .disabled(!isFormValid || isSubmitting)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .padding(.bottom, 32)
                }
                .background(Theme.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 4)
            }
        }
        .alert("Spot Listed!", isPresented: $showSuccess) {
            Button("OK") { clearForm() }
        } message: {
            Text("Your spot is now live. We'll notify matched buyers.")
        }
    }

    // MARK: - Helpers

    var isFormValid: Bool {
        !studioName.isEmpty && !className.isEmpty && !location.isEmpty &&
        !studioEmail.isEmpty && !studioPassword.isEmpty
    }

    func submitListing() async {
        guard let userId = authVM.currentUser?.id else { return }
        isSubmitting = true

        do {
            // In production: encrypt credentials via Supabase Edge Function
            let credentialPayload = "\(studioEmail):::\(studioPassword)"

            _ = try await listingService.createListing(
                listerId: userId,
                studioName: studioName,
                className: className,
                classType: classType,
                dateTime: classDate,
                location: location,
                originalPrice: Double(originalPrice),
                encryptedCredentials: credentialPayload, // TODO: encrypt via Edge Function
                additionalNotes: additionalNotes.isEmpty ? nil : additionalNotes
            )
            showSuccess = true
        } catch {
            print("Failed to create listing: \(error)")
        }
        isSubmitting = false
    }

    func clearForm() {
        studioName = ""
        className = ""
        classDate = Date()
        location = ""
        originalPrice = ""
        studioEmail = ""
        studioPassword = ""
        additionalNotes = ""
    }

    // Reusable form section
    func formSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.sectionTitle())
                .padding(.horizontal, 16)
                .padding(.top, 8)
            content()
        }
    }

    func formField(_ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 16)
    }
}
