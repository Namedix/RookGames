import SwiftUI

/// Brand wordmark.
///
/// Currently a `Text("rook")` filled with the brand gradient. Once the SVG
/// export of the styleguide wordmark lands at
/// `Rook/Resources/Assets.xcassets/Brand/RookWordmark.imageset/`, swap the
/// implementation to `Image("RookWordmark")` — call sites will not change.
struct RookWordmark: View {
    enum Size {
        case small
        case medium
        case large

        var font: RookFont {
            switch self {
            case .small:  .title2
            case .medium: .title
            case .large:  .largeTitle
            }
        }
    }

    var size: Size = .large

    var body: some View {
        Text("rook")
            .rookFont(size.font)
            .foregroundStyle(LinearGradient.rookBrand)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("Rook")
    }
}

#Preview {
    VStack(spacing: RookSpacing.l) {
        RookWordmark(size: .small)
        RookWordmark(size: .medium)
        RookWordmark(size: .large)
    }
    .padding()
    .background(Color.rookBackground)
}
