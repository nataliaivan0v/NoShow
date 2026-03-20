import Foundation

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading = false
    @Published var selectedClassType: ClassType?
    @Published var searchText = ""

    private let listingService = ListingService()

    func loadListings() async {
        isLoading = true
        do {
            if let classType = selectedClassType {
                listings = try await listingService.getListingsByType(classType: classType)
            } else {
                listings = try await listingService.getActiveListings()
            }
        } catch {
            print("Failed to load listings: \(error)")
        }
        isLoading = false
    }

    func filterByType(_ type: ClassType?) async {
        selectedClassType = type
        await loadListings()
    }

    var filteredListings: [Listing] {
        if searchText.isEmpty { return listings }
        return listings.filter {
            $0.studioName.localizedCaseInsensitiveContains(searchText) ||
            $0.className.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }
}
