import SwiftUI

struct RookCardModifier: ViewModifier {
    var padding: CGFloat = RookSpacing.l
    var radius: CGFloat = RookRadius.l
    var fill: Color = .rookSurface

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
            )
    }
}

extension View {
    /// Wraps the receiver in the standard Rook card surface (rounded
    /// `rookSurface` with `RookSpacing.l` padding).
    func rookCard(
        padding: CGFloat = RookSpacing.l,
        radius: CGFloat = RookRadius.l,
        fill: Color = .rookSurface
    ) -> some View {
        modifier(RookCardModifier(padding: padding, radius: radius, fill: fill))
    }
}
