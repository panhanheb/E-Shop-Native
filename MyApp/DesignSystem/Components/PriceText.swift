import SwiftUI

/// Shows a price, with the original price struck through when discounted.
struct PriceText: View {
    private let price: Decimal
    private let originalPrice: Decimal?
    private let font: Font

    /// Creates a price label.
    /// - Parameters:
    ///   - price: Current selling price.
    ///   - originalPrice: Pre-discount price, shown struck through when higher than `price`.
    ///   - font: Font for the current price.
    init(_ price: Decimal, originalPrice: Decimal? = nil, font: Font = AppFont.headline) {
        self.price = price
        self.originalPrice = originalPrice
        self.font = font
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
            Text(price, format: .currency(code: AppCurrency.code))
                .font(font)
                .foregroundStyle(originalPrice.map { $0 > price } == true ? AppColors.primary : AppColors.textPrimary)

            if let originalPrice, originalPrice > price {
                Text(originalPrice, format: .currency(code: AppCurrency.code))
                    .font(AppFont.caption)
                    .strikethrough()
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
        PriceText(12.5)
        PriceText(59.99, originalPrice: 79.99)
        PriceText(129, font: AppFont.title)
    }
    .padding()
}
