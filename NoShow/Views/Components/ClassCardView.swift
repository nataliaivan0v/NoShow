import SwiftUI

struct ClassCardView: View {
    let listing: Listing
    var showCountdown: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(listing.className)
                    .font(Theme.sectionTitle())
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                if showCountdown {
                    CountdownTimer(targetDate: listing.dateTime)
                }
            }

            Text(listing.studioName)
                .font(Theme.body())
                .foregroundColor(Theme.textSecondary)

            HStack {
                Text(listing.dateTime, style: .date)
                Text("at")
                Text(listing.dateTime, style: .time)
            }
            .font(Theme.caption())
            .foregroundColor(Theme.textSecondary)

            Text(listing.location)
                .font(Theme.caption())
                .foregroundColor(Theme.textSecondary)

            HStack {
                Text("$\(String(format: "%.0f", listing.askingPrice))")
                    .font(Theme.sectionTitle())
                    .foregroundColor(Theme.orange)

                if let original = listing.originalPrice {
                    Text("$\(String(format: "%.0f", original))")
                        .font(Theme.caption())
                        .strikethrough()
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Text(listing.classType.rawValue)
                    .font(Theme.caption())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.orange.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
