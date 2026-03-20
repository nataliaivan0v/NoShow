import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    let listing: Listing

    @State private var showClaimConfirmation = false
    @State private var isClaiming = false
    @State private var claimedTransaction: Transaction?

    private let transactionService = TransactionService()

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Class info card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(listing.className)
                                    .font(Theme.screenTitle())
                                Spacer()
                                CountdownTimer(targetDate: listing.dateTime)
                            }

                            Text(listing.studioName)
                                .font(Theme.body())
                                .foregroundColor(Theme.textSecondary)

                            Divider()

                            infoRow(icon: "calendar", label: "Date", value: listing.dateTime.formatted(date: .abbreviated, time: .omitted))
                            infoRow(icon: "clock", label: "Time", value: listing.dateTime.formatted(date: .omitted, time: .shortened))
                            infoRow(icon: "mappin.circle", label: "Location", value: listing.location)
                            infoRow(icon: "figure.run", label: "Type", value: listing.classType.rawValue)

                            if let notes = listing.additionalNotes, !notes.isEmpty {
                                Divider()
                                Text("Notes from lister")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.textSecondary)
                                Text(notes)
                                    .font(Theme.body())
                            }

                            Divider()

                            // Pricing
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Your price")
                                        .font(Theme.caption())
                                        .foregroundColor(Theme.textSecondary)
                                    Text("$\(String(format: "%.0f", listing.askingPrice))")
                                        .font(Theme.heroTitle())
                                        .foregroundColor(Theme.orange)
                                }

                                Spacer()

                                if let original = listing.originalPrice {
                                    VStack(alignment: .trailing) {
                                        Text("Original")
                                            .font(Theme.caption())
                                            .foregroundColor(Theme.textSecondary)
                                        Text("$\(String(format: "%.0f", original))")
                                            .font(Theme.sectionTitle())
                                            .strikethrough()
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                    }
                    .padding(16)
                }

                // Claim button
                if claimedTransaction != nil {
                    NavigationLink(destination: CredentialRevealView(listing: listing)) {
                        Text("VIEW CREDENTIALS")
                            .font(Theme.buttonLabel())
                            .foregroundColor(Theme.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                } else {
                    SecondaryButton(title: isClaiming ? "Claiming..." : "CLAIM THIS SPOT") {
                        showClaimConfirmation = true
                    }
                    .disabled(isClaiming)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .alert("Claim this spot?", isPresented: $showClaimConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Claim for $\(String(format: "%.0f", listing.askingPrice))") {
                Task { await claimSpot() }
            }
        } message: {
            Text("You'll receive the studio login credentials to check into this class.")
        }
    }

    func claimSpot() async {
        guard let buyerId = authVM.currentUser?.id else { return }
        isClaiming = true
        do {
            claimedTransaction = try await transactionService.claimSpot(
                listingId: listing.id,
                buyerId: buyerId,
                amount: listing.askingPrice
            )
        } catch {
            print("Failed to claim spot: \(error)")
        }
        isClaiming = false
    }

    func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.orange)
                .frame(width: 24)
            Text(label)
                .font(Theme.caption())
                .foregroundColor(Theme.textSecondary)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(Theme.body())
        }
    }
}
