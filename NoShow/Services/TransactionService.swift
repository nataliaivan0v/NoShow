import Foundation
import Supabase

class TransactionService {
    private let client = SupabaseConfig.client

    /// Claim a spot — creates transaction and updates listing status
    func claimSpot(listingId: UUID, buyerId: UUID, amount: Double) async throws -> Transaction {
        // Update listing to claimed
        try await client.from("listings")
            .update(["status": ListingStatus.claimed.rawValue])
            .eq("id", value: listingId.uuidString)
            .execute()

        // Create transaction
        let newTransaction: [String: AnyJSON] = [
            "listing_id": .string(listingId.uuidString),
            "buyer_id": .string(buyerId.uuidString),
            "amount": .double(amount),
            "status": .string(TransactionStatus.pending.rawValue),
            "credentials_revealed_at": .string(ISO8601DateFormatter().string(from: Date()))
        ]

        let transaction: Transaction = try await client.from("transactions")
            .insert(newTransaction)
            .select()
            .single()
            .execute()
            .value

        return transaction
    }

    /// Get all transactions for a buyer
    func getMyClaimedSpots(buyerId: UUID) async throws -> [Transaction] {
        let transactions: [Transaction] = try await client.from("transactions")
            .select()
            .eq("buyer_id", value: buyerId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return transactions
    }

    /// Request refund (credentials didn't work)
    func requestRefund(transactionId: UUID) async throws {
        try await client.from("transactions")
            .update(["status": TransactionStatus.refunded.rawValue])
            .eq("id", value: transactionId.uuidString)
            .execute()
    }
}
