import SwiftUI

/// Decorative illustration of beauty products (serum, tube, perfume, jar) on a marble stand.
/// Used in banners until real campaign images are available.
struct BeautyArtworkView: View {
    var scale: CGFloat = 1

    private let roseGold = LinearGradient(
        colors: [Color(hex: 0xF3C7B5), Color(hex: 0xD99A86)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    private let cream = LinearGradient(
        colors: [Color(hex: 0xFFF6F0), Color(hex: 0xEED7CA)],
        startPoint: .top,
        endPoint: .bottom
    )
    private let amber = LinearGradient(
        colors: [Color(hex: 0xF6DDB8), Color(hex: 0xD9A96A)],
        startPoint: .top,
        endPoint: .bottom
    )
    private let gold = Color(hex: 0xC9965B)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Marble stand
            RoundedRectangle(cornerRadius: 6 * scale)
                .fill(LinearGradient(colors: [.white, Color(hex: 0xEDE4DE)], startPoint: .top, endPoint: .bottom))
                .frame(width: 150 * scale, height: 16 * scale)
                .shadow(color: AppColors.shadow, radius: 4, y: 2)

            HStack(alignment: .bottom, spacing: 6 * scale) {
                // Dropper serum
                VStack(spacing: 0) {
                    Capsule().fill(gold).frame(width: 10 * scale, height: 22 * scale)
                    RoundedRectangle(cornerRadius: 3 * scale).fill(gold).frame(width: 18 * scale, height: 10 * scale)
                    bottleBody(roseGold, width: 30, height: 62, label: "GLOW")
                }

                // Tube
                VStack(spacing: 0) {
                    bottleBody(cream, width: 34, height: 92, label: "LUXE", cornerRadius: 8)
                    RoundedRectangle(cornerRadius: 3 * scale).fill(gold).frame(width: 26 * scale, height: 12 * scale)
                }

                // Perfume
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4 * scale).fill(gold).frame(width: 22 * scale, height: 16 * scale)
                    bottleBody(amber, width: 44, height: 50, label: "ROSE", cornerRadius: 10)
                }
            }
            .padding(.bottom, 14 * scale)
            .overlay(alignment: .bottomTrailing) {
                // Jar
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4 * scale).fill(gold).frame(width: 44 * scale, height: 10 * scale)
                    bottleBody(cream, width: 48, height: 24, label: "LUXE", cornerRadius: 6)
                }
                .offset(x: 10 * scale, y: -8 * scale)
            }

            Image(systemName: AppImages.brand)
                .font(.system(size: 14 * scale))
                .foregroundStyle(gold)
                .offset(x: -70 * scale, y: -110 * scale)
        }
        .accessibilityHidden(true)
    }

    private func bottleBody(
        _ fill: LinearGradient,
        width: CGFloat,
        height: CGFloat,
        label: String,
        cornerRadius: CGFloat = 6
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius * scale)
            .fill(fill)
            .frame(width: width * scale, height: height * scale)
            .overlay {
                Text(verbatim: label)
                    .font(.system(size: 6 * scale, weight: .semibold, design: .serif))
                    .kerning(1)
                    .foregroundStyle(Color(hex: 0x8A5A44))
            }
            .shadow(color: AppColors.shadow, radius: 3, x: 1, y: 2)
    }
}

#Preview {
    BeautyArtworkView()
        .frame(width: 200, height: 180)
        .background(AppColors.primarySoft)
}
