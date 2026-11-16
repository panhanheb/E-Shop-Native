import SwiftUI

extension Color {
    /// Creates a color from a hex value such as `0x5856D6`.
    /// - Parameters:
    ///   - hex: 24-bit RGB value.
    ///   - opacity: Alpha component from 0 to 1.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
