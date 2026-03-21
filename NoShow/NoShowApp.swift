import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated && authVM.currentUser != nil {
                MainTabView()
            } else {
                LandingView()
            }
        }
        .animation(.easeInOut, value: authVM.currentUser != nil)
    }
}
