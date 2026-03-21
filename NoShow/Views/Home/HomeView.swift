import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var selectedTab: Tab
    @Binding var showHome: Bool

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi \(authVM.currentUser?.firstName ?? "there"),")
                        .font(Theme.screenTitle())
                        .foregroundColor(Theme.white)
                    Text("Welcome to")
                        .font(Theme.screenTitle())
                        .foregroundColor(Theme.white)
                    Text("No Show")
                        .font(Theme.heroTitle())
                        .italic()
                        .foregroundColor(Theme.white)

                    if let neighborhood = authVM.currentUser?.neighborhood, !neighborhood.isEmpty {
                        Text("Browsing classes near \(neighborhood)")
                            .font(Theme.caption())
                            .foregroundColor(Theme.white.opacity(0.7))
                            .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)

                Spacer()

                // Action buttons
                VStack(spacing: 14) {
                    Text("Let's get started!")
                        .font(Theme.body())
                        .foregroundColor(Theme.white.opacity(0.85))

                    PrimaryButton(title: "I WANT TO LIST A CLASS") {
                        selectedTab = .create
                        showHome = false
                    }

                    PrimaryButton(title: "I WANT TO TAKE A CLASS") {
                        selectedTab = .browse
                        showHome = false
                    }

                    PrimaryButton(title: "TAKE ME TO MY DASHBOARD") {
                        selectedTab = .dashboard
                        showHome = false
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}
