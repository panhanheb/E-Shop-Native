import SwiftUI

/// Rounded surface container used to group related content.
struct CardView<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

    /// Creates a card wrapping `content`.
    init(padding: CGFloat = AppSpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
    }
}

/// The standard card look: surface fill, hairline border, and a soft shadow.
struct CardStyleModifier: ViewModifier {
    var cornerRadius: CGFloat = AppRadius.large
    var hasShadow = true

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(AppColors.surface, in: shape)
            .overlay(shape.strokeBorder(AppColors.hairline, lineWidth: 0.5))
            .shadow(color: hasShadow ? AppColors.shadow : .clear, radius: 8, y: 2)
    }
}

extension View {
    /// Applies the standard card background, border, and shadow.
    func cardStyle(cornerRadius: CGFloat = AppRadius.large, hasShadow: Bool = true) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, hasShadow: hasShadow))
    }
}

/// Slight shrink and fade while pressed, for custom tappable cards and buttons.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    /// Shrinks slightly while pressed.
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Card Title").font(AppFont.headline)
                Text("Supporting text inside a card.").font(AppFont.callout)
            }
        }
        Button("Pressable") {}
            .buttonStyle(.pressable)
    }
    .padding()
    .background(AppColors.background)
}
