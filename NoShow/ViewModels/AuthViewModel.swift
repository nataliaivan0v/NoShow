import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var awaitingOTP = false

    private let authService = AuthService()
    private var pendingPhone: String = ""

    init() {
        Task { await checkSession() }
    }

    func checkSession() async {
        if let session = await authService.getCurrentSession() {
            do {
                currentUser = try await authService.getProfile(userId: session.user.id)
                isAuthenticated = true
            } catch {
                isAuthenticated = false
            }
        }
    }

    func sendOTP(phone: String) async {
        isLoading = true
        errorMessage = nil
        pendingPhone = phone
        do {
            try await authService.sendOTP(phone: phone)
            awaitingOTP = true
        } catch {
            errorMessage = "Failed to send code. Check your phone number."
        }
        isLoading = false
    }

    func verifyOTP(code: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let session = try await authService.verifyOTP(phone: pendingPhone, code: code)
            // Try to load existing profile, or mark as new user
            do {
                currentUser = try await authService.getProfile(userId: session.user.id)
            } catch {
                // New user — profile will be created in signup flow
                currentUser = nil
            }
            isAuthenticated = true
        } catch {
            errorMessage = "Invalid code. Please try again."
        }
        isLoading = false
    }

    func createProfile(firstName: String) async {
        guard let session = await authService.getCurrentSession() else { return }
        do {
            try await authService.createProfile(
                userId: session.user.id,
                firstName: firstName,
                phone: pendingPhone
            )
            currentUser = try await authService.getProfile(userId: session.user.id)
        } catch {
            errorMessage = "Failed to create profile."
        }
    }

    func signOut() async {
        try? await authService.signOut()
        isAuthenticated = false
        currentUser = nil
    }
}
