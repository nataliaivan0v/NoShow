import Foundation

enum ListingStatus: String, Codable {
    case active
    case claimed
    case expired
    case cancelled
}

enum ClassType: String, Codable, CaseIterable, Identifiable {
    case yoga = "Yoga"
    case pilates = "Pilates"
    case cycling = "Cycling"
    case boxing = "Boxing"
    case barre = "Barre"
    case hiit = "HIIT"
    case strength = "Strength"
    case dance = "Dance"
    case rowing = "Rowing"
    case other = "Other"

    var id: String { rawValue }
}

struct Listing: Codable, Identifiable {
    let id: UUID
    let listerId: UUID
    var studioName: String
    var className: String
    var classType: ClassType
    var dateTime: Date
    var location: String
    var originalPrice: Double?
    var askingPrice: Double
    var encryptedCredentials: String
    var additionalNotes: String?
    var status: ListingStatus
    var createdAt: Date
    var expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case listerId = "lister_id"
        case studioName = "studio_name"
        case className = "class_name"
        case classType = "class_type"
        case dateTime = "date_time"
        case location
        case originalPrice = "original_price"
        case askingPrice = "asking_price"
        case encryptedCredentials = "encrypted_credentials"
        case additionalNotes = "additional_notes"
        case status
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }

    var minutesUntilClass: Int {
        Int(dateTime.timeIntervalSinceNow / 60)
    }

    var isExpired: Bool {
        Date() >= expiresAt
    }
}
