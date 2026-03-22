import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showHome = true

    var body: some View {
        ZStack {
            if showHome {
                HomeView(selectedTab: $selectedTab, showHome: $showHome)
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
                        case .profile:
                            ProfileView()
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
