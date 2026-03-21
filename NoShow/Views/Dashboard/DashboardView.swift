import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My dashboard")
                        .font(Theme.screenTitle())
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text("No Show")
                        .font(Theme.logoCorner())
                        .italic()
                        .foregroundColor(Theme.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Theme.orange)

                // Scrollable content
                ScrollView {
                    VStack(spacing: 16) {
                        // Upcoming Classes
                        DashboardSection(
                            title: "Upcoming Classes",
                            listings: vm.upcomingClasses,
                            emptyMessage: "No upcoming classes"
                        )

                        // Listed Classes
                        DashboardSection(
                            title: "Listed Classes",
                            listings: vm.myListings,
                            emptyMessage: "No active listings"
                        )

                        // Past Classes
                        DashboardSection(
                            title: "Past Classes",
                            listings: vm.pastClasses,
                            emptyMessage: "No past classes"
                        )
                    }
                    .padding(16)
                }
                .background(Theme.orange)
            }
        }
        .task {
            if let userId = authVM.currentUser?.id {
                await vm.loadDashboard(userId: userId)
            }
        }
    }
}

struct DashboardSection: View {
    let title: String
    let listings: [Listing]
    let emptyMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.sectionTitle())
                .foregroundColor(Theme.textPrimary)

            if listings.isEmpty {
                Text(emptyMessage)
                    .font(Theme.caption())
                    .foregroundColor(Theme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(listings) { listing in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(listing.className)
                            .font(Theme.body())
                            .fontWeight(.semibold)
                        Text("\(listing.dateTime, style: .date) at \(listing.dateTime, style: .time)")
                            .font(Theme.caption())
                            .foregroundColor(Theme.textSecondary)
                        Text(listing.location)
                            .font(Theme.caption())
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }
}
