import Dependencies
import SwiftUI

@MainActor
@Observable
final class ImportBarcodeModel: ImportMethodModel {
    var detectedBarcodes: [String] = []
    var resolvedGames: [Game] = []
    var unresolvedBarcodes: [String] = []
    var isScanning = false
    var errorMessage: String?

    var onConfirm: ([Game]) -> Void = { _ in }

    @ObservationIgnored @Dependency(\.barcodeScanner) var scanner
    @ObservationIgnored @Dependency(\.gameCatalog) var catalog

    init() {}

    func task() async {
        isScanning = true
        defer { isScanning = false }
        for await barcode in scanner.scan() {
            await handle(barcode: barcode)
        }
    }

    private func handle(barcode: String) async {
        guard !detectedBarcodes.contains(barcode) else { return }
        detectedBarcodes.append(barcode)
        do {
            if let game = try await catalog.lookupBarcode(barcode: barcode) {
                if !resolvedGames.contains(where: { $0.id == game.id }) {
                    resolvedGames.append(game)
                }
            } else {
                unresolvedBarcodes.append(barcode)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ game: Game) {
        resolvedGames.removeAll { $0.id == game.id }
    }

    func confirmButtonTapped() {
        guard !resolvedGames.isEmpty else { return }
        onConfirm(resolvedGames)
    }
}

extension ImportBarcodeModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: ImportBarcodeModel, rhs: ImportBarcodeModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
