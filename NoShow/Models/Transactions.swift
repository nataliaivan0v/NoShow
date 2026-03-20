import Foundation

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case refunded
    case disputed
}

struct Transaction: Codable, Identifiable {
    let id: UUID
    let listingId: UUID
    let buyerId: UUID
    var amount: Double
    var status: TransactionStatus
    var credentialsRevealedAt: Date?
    var credentialsDeletedAt: Date?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case listingId = "listing_id"
        case buyerId = "buyer_id"
        case amount
        case status
        case credentialsRevealedAt = "credentials_revealed_at"
        case credentialsDeletedAt = "credentials_deleted_at"
        case createdAt = "created_at"
    }
}
