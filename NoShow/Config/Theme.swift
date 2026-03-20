import SwiftUI

struct Theme {
    // Colors
    static let orange = Color(hex: "E07A3A")
    static let black = Color.black
    static let white = Color.white
    static let cardBackground = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color.gray

    // Fonts
    static func heroTitle() -> Font {
        .system(size: 48, weight: .bold, design: .serif)
    }

    static func screenTitle() -> Font {
        .system(size: 32, weight: .bold, design: .serif)
    }

    static func sectionTitle() -> Font {
        .system(size: 20, weight: .bold, design: .default)
    }

    static func body() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    static func caption() -> Font {
        .system(size: 14, weight: .regular, design: .default)
    }

    static func buttonLabel() -> Font {
        .system(size: 16, weight: .semibold, design: .default)
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
