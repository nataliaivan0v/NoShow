import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showHome = true

    var body: some View {
        ZStack {
            if showHome {
                HomeView(selectedTab: $selectedTab)
                    .onChange(of: selectedTab) { _, _ in
                        showHome = false
                    }
            } else {
                VStack(spacing: 0) {
                    // Content
                    Group {
                        switch selectedTab {
                        case .browse:
                            BrowseView()
                        case .create:
                            CreateListingView()
                        case .dashboard:
                            DashboardView()
                        }
                    }
                    .frame(maxHeight: .infinity)

                    // Bottom tab bar
                    TabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}
