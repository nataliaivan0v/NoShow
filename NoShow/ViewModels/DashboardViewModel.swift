import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var myListings: [Listing] = []
    @Published var upcomingClasses: [Listing] = [] // claimed spots
    @Published var pastClasses: [Listing] = []
    @Published var isLoading = false

    private let listingService = ListingService()
    private let transactionService = TransactionService()

    func loadDashboard(userId: UUID) async {
        isLoading = true
        do {
            let allListings = try await listingService.getMyListings(userId: userId)
            let now = Date()

            // Listings I created that are still active
            myListings = allListings.filter { $0.status == .active }

            // Past = expired, claimed, or cancelled
            pastClasses = allListings.filter {
                $0.status == .expired || $0.status == .cancelled || ($0.status == .claimed && $0.dateTime < now)
            }
        } catch {
            print("Failed to load dashboard: \(error)")
        }
        isLoading = false
    }
}
