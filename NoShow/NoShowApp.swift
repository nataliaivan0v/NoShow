import SwiftUI

#Preview {
    struct ContentView: View {
        @EnvironmentObject var authVM: AuthViewModel

        var body: some View {
            Group {
                if authVM.isAuthenticated {
                    MainTabView()
                } else {
                    LandingView()
                }
            }
            .animation(.easeInOut, value: authVM.isAuthenticated)
        }
    }
}
