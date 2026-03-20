import Foundation
import Supabase

class AuthService {
    private let client = SupabaseConfig.client

    func sendOTP(phone: String) async throws {
        try await client.auth.signInWithOTP(phone: phone)
    }

    func verifyOTP(phone: String, code: String) async throws -> Session {
        let session = try await client.auth.verifyOTP(
            phone: phone,
            token: code,
            type: .sms
        )
        return session
    }

    func createProfile(userId: UUID, firstName: String, phone: String) async throws {
        let profile: [String: String] = [
            "id": userId.uuidString,
            "first_name": firstName,
            "phone_number": phone
        ]
        try await client.from("users").insert(profile).execute()
    }

    func getProfile(userId: UUID) async throws -> AppUser {
        let response: AppUser = try await client.from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        return response
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    /// Get current session
    func getCurrentSession() async -> Session? {
        try? await client.auth.session
    }
}
