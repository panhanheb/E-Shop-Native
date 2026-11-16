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
        HStack(spacing: AppSpacing.sm) {
            Button(action: onDecrease) {
                Image(systemName: AppImages.remove)
                    .frame(width: 32, height: 32)
            }
            .disabled(!canDecrease)
            .accessibilityLabel("Decrease quantity")

            Text(quantity, format: .number)
                .font(AppFont.headline)
                .monospacedDigit()
                .frame(minWidth: 28)
                .accessibilityIdentifier("quantity.value")

            Button(action: onIncrease) {
                Image(systemName: AppImages.add)
                    .frame(width: 32, height: 32)
            }
            .disabled(!canIncrease)
            .accessibilityLabel("Increase quantity")
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, AppSpacing.xs)
        .background(AppColors.background, in: Capsule())
    }
}

#Preview {
    QuantityStepper(quantity: 2, canDecrease: true, canIncrease: false, onDecrease: {}, onIncrease: {})
        .padding()
}
