import Foundation
import Supabase

class AuthService {
    private let client = SupabaseConfig.client

    /// Send OTP to phone number
    func sendOTP(phone: String) async throws {
        try await client.auth.signInWithOTP(phone: phone)
    }

    /// Verify OTP code
    func verifyOTP(phone: String, code: String) async throws -> Session {
        let response = try await client.auth.verifyOTP(
            phone: phone,
            token: code,
            type: .sms
        )
        guard let session = response.session else {
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session returned"])
        }
        return session
    }

    /// Create user profile after first login
    func createProfile(userId: UUID, firstName: String, phone: String) async throws {
        let profile: [String: String] = [
            "id": userId.uuidString,
            "first_name": firstName,
            "phone_number": phone
        ]
        try await client.from("users").insert(profile).execute()
    }

    /// Get current user profile
    func getProfile(userId: UUID) async throws -> AppUser {
        let response: AppUser = try await client.from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        return response
    }

    /// Sign out
    func signOut() async throws {
        try await client.auth.signOut()
    }

    /// Get current session
    func getCurrentSession() async -> Session? {
        try? await client.auth.session
    }
}
