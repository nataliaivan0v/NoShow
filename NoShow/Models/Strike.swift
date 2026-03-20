import Foundation

struct Strike: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let transactionId: UUID
    var reason: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case transactionId = "transaction_id"
        case reason
        case createdAt = "created_at"
    }
}
