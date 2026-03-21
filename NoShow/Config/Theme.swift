import SwiftUI

struct Theme {
    // Colors
    static let orange = Color(hex: "F35C20")
    static let black = Color.black
    static let white = Color.white
    static let cardBackground = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color.gray

    static let primaryFont = "Afacad-Regular"
    static let primaryFontBold = "Afacad-Bold"
    static let primaryFontSemiBold = "Afacad-SemiBold"
    static let primaryFontMedium = "Afacad-Medium"
    static let logoFont = "BerkshireSwash-Regular"
    
    // Fonts
    static func heroTitle() -> Font {
            .custom(logoFont, size: 64)
        }
    
    static func logoCorner() -> Font {
            .custom(logoFont, size: 24)
        }

        static func screenTitle() -> Font {
            .custom(primaryFontBold, size: 32)
        }

        static func sectionTitle() -> Font {
            .custom(primaryFontBold, size: 20)
        }

        static func body() -> Font {
            .custom(primaryFontMedium, size: 16)
        }

        static func caption() -> Font {
            .custom(primaryFontMedium, size: 16)
        }

        static func buttonLabel() -> Font {
            .custom(primaryFontMedium, size: 16)
        }
    }

// Hex color initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
