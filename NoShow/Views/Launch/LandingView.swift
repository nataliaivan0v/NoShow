import SwiftUI

struct LandingView: View {
    @State private var showLogin = false
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.orange.ignoresSafeArea()

                VStack {
                    Spacer()

                    // Logo
                    Text("No Show")
                        .font(Theme.heroTitle())
                        .italic()
                        .foregroundColor(Theme.white)

                    // Tagline
                    Text("Skip the No-Show, Let It Go!\nShare Your Spot, Save Your Fee!")
                        .font(Theme.caption())
                        .foregroundColor(Theme.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    Spacer()
                    Spacer()

                    // Subtitle
                    Text("Whether you want to list\na class or take a class, first")
                        .font(Theme.body())
                        .foregroundColor(Theme.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)

                    // Buttons
                    VStack(spacing: 12) {
                        PrimaryButton(title: "Log In") {
                            showLogin = true
                        }
                        SecondaryButton(title: "Sign Up") {
                            showSignUp = true
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
