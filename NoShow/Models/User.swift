import Foundation

struct AppUser: Codable, Identifiable {
    let id: UUID
    var phoneNumber: String
    var firstName: String
    var lastName: String
    var birthDate: Date
    var email: String
    var gender: String
    var createdAt: Date
    var notificationPreferences: NotificationPreferences?

    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case email
        case gender
        case createdAt = "created_at"
        case notificationPreferences = "notification_preferences"
    }
}

struct NotificationPreferences: Codable {
    var classTypes: [String]     // yoga, cycling, boxing, etc.
    var studios: [String]        // studio names
    var radiusMiles: Double      // neighborhood radius
    var preferredTimes: [String] // morning, afternoon, evening

    enum CodingKeys: String, CodingKey {
        case classTypes = "class_types"
        case studios
        case radiusMiles = "radius_miles"
        case preferredTimes = "preferred_times"
    }
}
