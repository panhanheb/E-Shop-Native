import SwiftUI

/// Circular avatar showing the user's initials.
struct AvatarView: View {
    /// Full name used to derive initials.
    let name: String
    /// Diameter in points.
    var size: CGFloat = 72

    private var initials: String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    var body: some View {
        Circle()
            .fill(AppColor.primary.gradient)
            .frame(width: size, height: size)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        AvatarView(name: "Alex Morgan")
        AvatarView(name: "Sam", size: 44)
    }
}
