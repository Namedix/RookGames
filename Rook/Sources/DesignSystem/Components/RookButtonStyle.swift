import SwiftUI

struct RookPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .rookFont(.headline)
            .foregroundStyle(Color.rookForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, RookSpacing.m)
            .padding(.horizontal, RookSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                    .fill(LinearGradient.rookBrand)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                    .fill(Color.black.opacity(configuration.isPressed ? 0.18 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct RookSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .rookFont(.headline)
            .foregroundStyle(Color.rookAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, RookSpacing.m)
            .padding(.horizontal, RookSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                    .fill(Color.rookSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                    .stroke(Color.rookAccent.opacity(0.55), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == RookPrimaryButtonStyle {
    static var rookPrimary: RookPrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == RookSecondaryButtonStyle {
    static var rookSecondary: RookSecondaryButtonStyle { .init() }
}
