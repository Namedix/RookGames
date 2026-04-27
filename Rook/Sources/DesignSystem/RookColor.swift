import SwiftUI

// MARK: - Color tokens
//
// These wrap Tuist's synthesized `RookAsset` namespace (see
// `Derived/Sources/TuistAssets+Rook.swift`). Adding a new `.colorset` under
// `Rook/Resources/Assets.xcassets/Colors/` automatically updates `RookAsset` —
// just expose it here so call sites stay `Color.rookSomething`.

extension Color {
    static var rookBackground: Color { RookAsset.rookBackground.swiftUIColor }
    static var rookSurface: Color { RookAsset.rookSurface.swiftUIColor }
    static var rookSurfaceElevated: Color { RookAsset.rookSurfaceElevated.swiftUIColor }
    static var rookSeparator: Color { RookAsset.rookSeparator.swiftUIColor }

    static var rookForeground: Color { RookAsset.rookForeground.swiftUIColor }
    static var rookForegroundSecondary: Color { RookAsset.rookForegroundSecondary.swiftUIColor }
    static var rookForegroundTertiary: Color { RookAsset.rookForegroundTertiary.swiftUIColor }

    static var rookAccent: Color { RookAsset.rookAccent.swiftUIColor }
    static var rookHighlight: Color { RookAsset.rookHighlight.swiftUIColor }

    static var rookGradientStart: Color { RookAsset.rookGradientStart.swiftUIColor }
    static var rookGradientEnd: Color { RookAsset.rookGradientEnd.swiftUIColor }
}

#if canImport(UIKit)
import UIKit

extension UIColor {
    static var rookBackground: UIColor { RookAsset.rookBackground.color }
    static var rookSurface: UIColor { RookAsset.rookSurface.color }
    static var rookSurfaceElevated: UIColor { RookAsset.rookSurfaceElevated.color }
    static var rookSeparator: UIColor { RookAsset.rookSeparator.color }

    static var rookForeground: UIColor { RookAsset.rookForeground.color }
    static var rookForegroundSecondary: UIColor { RookAsset.rookForegroundSecondary.color }
    static var rookForegroundTertiary: UIColor { RookAsset.rookForegroundTertiary.color }

    static var rookAccent: UIColor { RookAsset.rookAccent.color }
    static var rookHighlight: UIColor { RookAsset.rookHighlight.color }
}
#endif
