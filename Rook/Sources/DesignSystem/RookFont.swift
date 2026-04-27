import SwiftUI

/// Typography roles for the Rook design system.
///
/// Today every role resolves to `Font.system` with `design: .rounded` (the
/// SwiftUI default that ships with iOS). When we license Silka — or any other
/// custom face — only this file changes; call sites stay on `.rookFont(_:)`.
enum RookFont {
    case largeTitle
    case title
    case title2
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case mono

    struct Role {
        var size: CGFloat
        var weight: Font.Weight
        var design: Font.Design
    }

    var role: Role {
        switch self {
        case .largeTitle:  Role(size: 34, weight: .bold,     design: .rounded)
        case .title:       Role(size: 28, weight: .bold,     design: .rounded)
        case .title2:      Role(size: 22, weight: .semibold, design: .rounded)
        case .headline:    Role(size: 17, weight: .semibold, design: .rounded)
        case .body:        Role(size: 17, weight: .regular,  design: .rounded)
        case .callout:     Role(size: 16, weight: .regular,  design: .rounded)
        case .subheadline: Role(size: 15, weight: .medium,   design: .rounded)
        case .footnote:    Role(size: 13, weight: .regular,  design: .rounded)
        case .caption:     Role(size: 12, weight: .medium,   design: .rounded)
        case .mono:        Role(size: 14, weight: .regular,  design: .monospaced)
        }
    }

    var font: Font {
        let role = role
        return .system(size: role.size, weight: role.weight, design: role.design)
    }
}

extension View {
    func rookFont(_ font: RookFont) -> some View {
        self.font(font.font)
    }
}
