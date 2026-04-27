import Dependencies
import DependenciesMacros
import Foundation

/// Surface for the camera-backed barcode scanner. Today the live impl is
/// also mocked: it yields a single canned EAN-13 after a short delay so the
/// import flow can be exercised in the simulator without a real camera.
/// The real `AVCaptureSession + Vision` adapter will replace `liveValue`.
@DependencyClient
struct BarcodeScannerClient: Sendable {
    /// Long-running scan stream. Yields each detected barcode payload in
    /// the order they appear. Cancel the iteration to stop the session.
    var scan: @Sendable () -> AsyncStream<String> = { .finished }
}

extension BarcodeScannerClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.mock
}

extension DependencyValues {
    var barcodeScanner: BarcodeScannerClient {
        get { self[BarcodeScannerClient.self] }
        set { self[BarcodeScannerClient.self] = newValue }
    }
}

extension BarcodeScannerClient: DependencyKey {
    static let liveValue: Self = .mock
}

extension BarcodeScannerClient {
    /// Cycles through the same canned barcodes recognised by
    /// ``GameCatalogClient.lookupBarcode`` so the mock import flow can resolve
    /// each scan to a real game.
    static let mock: Self = {
        let payloads = [
            "0681706711461", // Gloomhaven
            "0810023363125", // Wingspan
            "0826956000389", // Azul
            "0810054590004", // Everdell
        ]

        return Self(
            scan: {
                AsyncStream { continuation in
                    let task = Task {
                        for payload in payloads {
                            if Task.isCancelled { break }
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            continuation.yield(payload)
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            }
        )
    }()
}
