import SwiftUI

extension LinearGradient {
    /// The brand coral-to-pink gradient used on primary CTAs, the wordmark and
    /// hero stats. Mirrors the iOS app icon background in the styleguide.
    static let rookBrand = LinearGradient(
        colors: [.rookGradientStart, .rookGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension ShapeStyle where Self == LinearGradient {
    static var rookBrand: LinearGradient { .rookBrand }
}
