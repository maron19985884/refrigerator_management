import SwiftUI

enum DesignTokens {
    enum Colors {
        static let backgroundDark = Color(hex: "#0A0A0F")
        static let surface = Color(hex: "#101018")
        static let neonBlue = Color(hex: "#00E5FF")
        static let neonBlueDeep = Color(hex: "#007ACC")
        static let neonPurple = Color(hex: "#A020F0")
        static let neonGreen = Color(hex: "#39FF14")   // 正解
        static let neonRed = Color(hex: "#FF073A")     // 不正解
        static let onDark = Color.white.opacity(0.92)
        static let onMuted = Color.white.opacity(0.7)
    }

    enum Typography {
        static let digitalMono = Font.system(.largeTitle, design: .monospaced)
        static let title = Font.system(size: 28, weight: .bold)
        static let body = Font.system(size: 17, weight: .regular)
    }

    enum Spacing {
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let m: CGFloat = 12
        static let l: CGFloat = 16
    }

    enum Elevation {
        struct Keycap: ViewModifier {
            func body(content: Content) -> some View {
                content.shadow(color: Colors.neonBlue.opacity(0.25), radius: 8, y: 2)
            }
        }
    }
}

extension View {
    func keycapShadow() -> some View {
        modifier(DesignTokens.Elevation.Keycap())
    }

    func glow(_ color: Color, radius: CGFloat = 12) -> some View {
        shadow(color: color, radius: radius)
    }
}

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hexString.count {
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: 1)
    }
}
