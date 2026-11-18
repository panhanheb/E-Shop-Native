import SwiftUI

/// Compact − / value / + control for choosing a quantity.
struct QuantityStepper: View {
    /// The value shown between the buttons.
    let quantity: Int
    /// Whether the − button is enabled.
    var canDecrease = true
    /// Whether the + button is enabled.
    var canIncrease = true
    /// Called when − is tapped.
    let onDecrease: () -> Void
    /// Called when + is tapped.
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            stepButton(AppImages.remove, isEnabled: canDecrease, action: onDecrease)
                .accessibilityLabel("Decrease quantity")

            Text(quantity, format: .number)
                .font(AppFont.headline)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(quantity)))
                .animation(.snappy, value: quantity)
                .frame(minWidth: 32)
                .accessibilityIdentifier("quantity.value")

            stepButton(AppImages.add, isEnabled: canIncrease, action: onIncrease)
                .accessibilityLabel("Increase quantity")
        }
        .padding(AppSpacing.xxs)
        .background(AppColors.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(AppColors.border.opacity(0.7), lineWidth: 1))
        .sensoryFeedback(.selection, trigger: quantity)
    }

    private func stepButton(_ systemImage: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isEnabled ? AppColors.primary : AppColors.textTertiary)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .buttonStyle(.borderless)
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        QuantityStepper(quantity: 2, onDecrease: {}, onIncrease: {})
        QuantityStepper(quantity: 9, canDecrease: true, canIncrease: false, onDecrease: {}, onIncrease: {})
    }
    .padding()
    .background(AppColors.background)
}
