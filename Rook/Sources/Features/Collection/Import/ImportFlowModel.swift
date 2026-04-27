import CasePaths
import Dependencies
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class ImportFlowModel {
    enum Method: Hashable, CaseIterable {
        case search
        case barcode
        case photo
    }

    var destination: Destination?

    /// Parent fills these in to flush results back into the collection.
    var onImport: ([Game]) -> Void = { _ in }
    var onCancel: () -> Void = {}

    @CasePathable
    @dynamicMemberLookup
    enum Destination {
        case search(ImportSearchModel)
        case barcode(ImportBarcodeModel)
        case photo(ImportPhotoModel)
    }

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func methodSelected(_ method: Method) {
        switch method {
        case .search:
            let m = withDependencies(from: self) { ImportSearchModel() }
            wireImport(m)
            destination = .search(m)
        case .barcode:
            let m = withDependencies(from: self) { ImportBarcodeModel() }
            wireImport(m)
            destination = .barcode(m)
        case .photo:
            let m = withDependencies(from: self) { ImportPhotoModel() }
            wireImport(m)
            destination = .photo(m)
        }
    }

    func backFromMethod() {
        destination = nil
    }

    func cancelButtonTapped() {
        onCancel()
    }

    private func wireImport<Model: ImportMethodModel>(_ model: Model) {
        model.onConfirm = { [weak self] games in
            self?.onImport(games)
        }
    }
}

extension ImportFlowModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: ImportFlowModel, rhs: ImportFlowModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

@MainActor
protocol ImportMethodModel: AnyObject {
    var onConfirm: ([Game]) -> Void { get set }
}
