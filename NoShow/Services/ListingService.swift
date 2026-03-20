import Foundation
import Supabase

class ListingService {
    private let client = SupabaseConfig.client

    /// Create a new listing
    func createListing(
        listerId: UUID,
        studioName: String,
        className: String,
        classType: ClassType,
        dateTime: Date,
        location: String,
        originalPrice: Double?,
        encryptedCredentials: String,
        additionalNotes: String?
    ) async throws -> Listing {
        let askingPrice = (originalPrice ?? 30.0) * 0.5 // fixed 50% split

        let newListing: [String: AnyJSON] = [
            "lister_id": .string(listerId.uuidString),
            "studio_name": .string(studioName),
            "class_name": .string(className),
            "class_type": .string(classType.rawValue),
            "date_time": .string(ISO8601DateFormatter().string(from: dateTime)),
            "location": .string(location),
            "original_price": .double(originalPrice ?? 30.0),
            "asking_price": .double(askingPrice),
            "encrypted_credentials": .string(encryptedCredentials),
            "additional_notes": .string(additionalNotes ?? ""),
            "status": .string(ListingStatus.active.rawValue),
            "expires_at": .string(ISO8601DateFormatter().string(from: dateTime))
        ]

        let listing: Listing = try await client.from("listings")
            .insert(newListing)
            .select()
            .single()
            .execute()
            .value

        return listing
    }

    /// Get all active listings (for browse feed)
    func getActiveListings() async throws -> [Listing] {
        let listings: [Listing] = try await client.from("listings")
            .select()
            .eq("status", value: ListingStatus.active.rawValue)
            .gt("expires_at", value: ISO8601DateFormatter().string(from: Date()))
            .order("date_time", ascending: true)
            .execute()
            .value
        return listings
    }

    /// Get active listings filtered by class type
    func getListingsByType(classType: ClassType) async throws -> [Listing] {
        let listings: [Listing] = try await client.from("listings")
            .select()
            .eq("status", value: ListingStatus.active.rawValue)
            .eq("class_type", value: classType.rawValue)
            .gt("expires_at", value: ISO8601DateFormatter().string(from: Date()))
            .order("date_time", ascending: true)
            .execute()
            .value
        return listings
    }

    /// Get a user's own listings
    func getMyListings(userId: UUID) async throws -> [Listing] {
        let listings: [Listing] = try await client.from("listings")
            .select()
            .eq("lister_id", value: userId.uuidString)
            .order("date_time", ascending: false)
            .execute()
            .value
        return listings
    }

    /// Cancel a listing
    func cancelListing(listingId: UUID) async throws {
        try await client.from("listings")
            .update(["status": ListingStatus.cancelled.rawValue])
            .eq("id", value: listingId.uuidString)
            .execute()
    }
}
