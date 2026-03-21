import Foundation

struct AppUser: Codable, Identifiable {
    let id: UUID
    var phoneNumber: String
    var firstName: String
    var lastName: String
    var age: Int
    var gender: String
    var neighborhood: String
    var createdAt: Date
    var notificationPreferences: NotificationPreferences?

    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case age
        case gender
        case neighborhood
        case createdAt = "created_at"
        case notificationPreferences = "notification_preferences"
    }
}

struct NotificationPreferences: Codable {
    var classTypes: [String]
    var studios: [String]
    var radiusMiles: Double
    var preferredTimes: [String]

    enum CodingKeys: String, CodingKey {
        case classTypes = "class_types"
        case studios
        case radiusMiles = "radius_miles"
        case preferredTimes = "preferred_times"
    }
}
