import PhotosUI
import SwiftUI

struct ImportPhotoView: View {
    @Bindable var model: ImportPhotoModel
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Photo import")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add (\(model.selectedIDs.count))") {
                    model.confirmButtonTapped()
                }
                .disabled(model.selectedIDs.isEmpty || model.status != .results)
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await model.photoSelected(data: data)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.status {
        case .picking:
            picker
        case .analyzing:
            analyzing
        case .results:
            results
        case let .failed(message):
            failed(message: message)
        }
    }

    private var picker: some View {
        VStack(spacing: RookSpacing.l) {
            Image(systemName: "photo.stack")
                .font(.system(size: 56))
                .foregroundStyle(LinearGradient.rookBrand)
            Text("Pick a photo")
                .rookFont(.title2)
                .foregroundStyle(Color.rookForeground)
            Text("Choose a clear shot of your shelf or a stack of boxes. We'll suggest games we recognize.")
                .rookFont(.body)
                .foregroundStyle(Color.rookForegroundSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RookSpacing.xl)
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label("Select photo", systemImage: "photo.on.rectangle.angled")
            }
            .buttonStyle(.rookPrimary)
            .padding(.horizontal, RookSpacing.xl)
        }
        .padding(RookSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var analyzing: some View {
        VStack(spacing: RookSpacing.l) {
            ProgressView().tint(.rookAccent)
            Text("Looking for games…")
                .rookFont(.headline)
                .foregroundStyle(Color.rookForeground)
            Text("This usually takes a couple of seconds.")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var results: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RookSpacing.m) {
                Text("We found \(model.candidates.count) games")
                    .rookFont(.headline)
                    .foregroundStyle(Color.rookForeground)
                Text("Tap to deselect anything that's wrong.")
                    .rookFont(.subheadline)
                    .foregroundStyle(Color.rookForegroundSecondary)
                ForEach(model.candidates) { game in
                    Button {
                        model.toggle(game)
                    } label: {
                        GameSelectionRow(
                            game: game,
                            isSelected: model.selectedIDs.contains(game.id)
                        )
                        .padding(.horizontal, RookSpacing.m)
                        .padding(.vertical, RookSpacing.s)
                        .background(
                            RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous)
                                .fill(Color.rookSurface)
                        )
                    }
                    .buttonStyle(.plain)
                }
                Button("Pick a different photo") {
                    pickerItem = nil
                    model.retryButtonTapped()
                }
                .buttonStyle(.rookSecondary)
                .padding(.top, RookSpacing.m)
            }
            .padding(.horizontal, RookSpacing.l)
            .padding(.vertical, RookSpacing.m)
        }
        .scrollContentBackground(.hidden)
    }

    private func failed(message: String) -> some View {
        VStack(spacing: RookSpacing.l) {
            ContentUnavailableView(
                "Couldn't read the photo",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
            .foregroundStyle(Color.rookForegroundSecondary)
            Button("Try again") {
                pickerItem = nil
                model.retryButtonTapped()
            }
            .buttonStyle(.rookPrimary)
            .padding(.horizontal, RookSpacing.xl)
        }
        .padding(RookSpacing.xl)
    }
}
