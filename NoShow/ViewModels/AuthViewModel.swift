import Foundation
import SwiftUI
internal import Combine
internal import Auth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var awaitingOTP = false

    // ⚠️ SET TO false BEFORE SHIPPING — this bypasses real auth
    private let devMode = true

    private let authService = AuthService()
    private var pendingPhone: String = ""

    init() {
        Task { await checkSession() }
    }

    func checkSession() async {
        if devMode { return }
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

        if devMode {
            awaitingOTP = true
            isLoading = false
            return
        }

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

        if devMode {
            // Skip real verification — accept any code
            isAuthenticated = true
            isLoading = false
            return
        }

        do {
            let session = try await authService.verifyOTP(phone: pendingPhone, code: code)
            do {
                currentUser = try await authService.getProfile(userId: session.user.id)
            } catch {
                currentUser = nil
            }
            isAuthenticated = true
        } catch {
            errorMessage = "Invalid code. Please try again."
        }
        isLoading = false
    }

    func createProfile(firstName: String, lastName: String, age: Int, gender: String, neighborhood: String) async {
        if devMode {
            currentUser = AppUser(
                id: UUID(),
                phoneNumber: pendingPhone.isEmpty ? "+16175550000" : pendingPhone,
                firstName: firstName,
                lastName: lastName,
                age: age,
                gender: gender,
                neighborhood: neighborhood,
                createdAt: Date(),
                notificationPreferences: nil
            )
            return
        }

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
        if devMode {
            isAuthenticated = false
            currentUser = nil
            awaitingOTP = false
            return
        }
        try? await authService.signOut()
        isAuthenticated = false
        currentUser = nil
    }
}
