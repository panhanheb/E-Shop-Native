import SwiftUI

/// Rounded surface container used to group related content.
struct CardView<Content: View>: View {
    private let content: Content

    /// Creates a card wrapping `content`.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.large))
    }
}

#Preview {
    CardView {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Card Title").font(AppFont.headline)
            Text("Supporting text inside a card.").font(AppFont.callout)
        }
    }
    .padding()
    .background(AppColor.background)
}
