import SwiftUI

enum Tab {
    case browse, create, dashboard, profile
}

struct TabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            Spacer()
            tabButton(icon: "magnifyingglass", tab: .browse)
            Spacer()
            tabButton(icon: "plus", tab: .create)
            Spacer()
            tabButton(icon: "house.fill", tab: .dashboard)
            Spacer()
            tabButton(icon: "person.fill", tab: .profile)
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Theme.white)
        .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
    }

    private func tabButton(icon: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(selectedTab == tab ? Theme.orange : Theme.textSecondary)
        }
    }
}
