import SwiftUI
import UIKit

/// One-shot theme bootstrap. Call from `RookApp.init`.
@MainActor
enum RookTheme {
    static func bootstrap() {
        configureNavigationBarAppearance()
        configureScrollViewAppearance()
    }

    private static func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .rookBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.rookForeground,
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.rookForeground,
        ]

        let proxy = UINavigationBar.appearance()
        proxy.standardAppearance = appearance
        proxy.scrollEdgeAppearance = appearance
        proxy.compactAppearance = appearance
        proxy.tintColor = .rookAccent
    }

    private static func configureScrollViewAppearance() {
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }
}
