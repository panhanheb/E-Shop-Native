import SwiftUI

/// Carousel position indicator: the current page is a wide brand-colored capsule.
struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AppColors.primary : AppColors.textTertiary.opacity(0.5))
                    .frame(width: index == current ? 18 : 6, height: 6)
            }
        }
        .animation(.easeInOut, value: current)
        .accessibilityHidden(true)
    }
}

#Preview {
    PageDots(count: 4, current: 1)
        .padding()
}
