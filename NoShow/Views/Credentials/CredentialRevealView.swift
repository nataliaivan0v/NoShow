import SwiftUI

struct CredentialRevealView: View {
    let listing: Listing
    @State private var credentialsVisible = false

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Your Credentials")
                    .font(Theme.screenTitle())
                    .foregroundColor(Theme.white)

                VStack(alignment: .leading, spacing: 16) {
                    Text(listing.className)
                        .font(Theme.sectionTitle())
                    Text("\(listing.studioName) • \(listing.dateTime, style: .time)")
                        .font(Theme.body())
                        .foregroundColor(Theme.textSecondary)

                    Divider()

                    if credentialsVisible {
                        // In production: decrypt via Edge Function call
                        let parts = listing.encryptedCredentials.components(separatedBy: ":::")
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.textSecondary)
                                Text(parts.first ?? "—")
                                    .font(Theme.body())
                                    .textSelection(.enabled)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.textSecondary)
                                Text(parts.count > 1 ? parts[1] : "—")
                                    .font(Theme.body())
                                    .textSelection(.enabled)
                            }
                        }
                    } else {
                        PrimaryButton(title: "Reveal Credentials") {
                            credentialsVisible = true
                        }
                    }

                    if credentialsVisible {
                        Divider()

                        if let notes = listing.additionalNotes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.textSecondary)
                                Text(notes)
                                    .font(Theme.body())
                            }
                        }
                    }
                }
                .padding(20)
                .background(Theme.cardBackground)
                .cornerRadius(16)

                if credentialsVisible {
                    Text("Credentials auto-delete after the class ends.\nUse the studio's app or website to check in.")
                        .font(Theme.caption())
                        .foregroundColor(Theme.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(20)
        }
    }
}
