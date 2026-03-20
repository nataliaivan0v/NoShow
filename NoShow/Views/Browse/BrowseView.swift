import SwiftUI

struct BrowseView: View {
    @StateObject private var vm = BrowseViewModel()

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Find a Class")
                        .font(Theme.screenTitle())
                        .foregroundColor(Theme.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.textSecondary)
                        TextField("Search studios, classes...", text: $vm.searchText)
                    }
                    .padding(12)
                    .background(Theme.white)
                    .cornerRadius(12)

                    // Class type filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip("All", isSelected: vm.selectedClassType == nil) {
                                Task { await vm.filterByType(nil) }
                            }
                            ForEach(ClassType.allCases) { type in
                                filterChip(type.rawValue, isSelected: vm.selectedClassType == type) {
                                    Task { await vm.filterByType(type) }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Listing feed
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if vm.isLoading {
                            ProgressView()
                                .tint(Theme.white)
                                .padding(.top, 40)
                        } else if vm.filteredListings.isEmpty {
                            VStack(spacing: 8) {
                                Text("No spots available right now")
                                    .font(Theme.body())
                                    .foregroundColor(Theme.white.opacity(0.8))
                                Text("Set your notification preferences\nto get alerted when spots open up")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                        } else {
                            ForEach(vm.filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    ClassCardView(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .task { await vm.loadListings() }
    }

    func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.caption())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.white : Theme.white.opacity(0.25))
                .foregroundColor(isSelected ? Theme.orange : Theme.white)
                .cornerRadius(20)
        }
    }
}
