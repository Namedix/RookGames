import SwiftUI

struct ImportBarcodeView: View {
    @Bindable var model: ImportBarcodeModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Scan barcode")
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.task() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add (\(model.resolvedGames.count))") {
                    model.confirmButtonTapped()
                }
                .disabled(model.resolvedGames.isEmpty)
            }
        }
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: RookSpacing.l) {
                viewfinder
                if !model.resolvedGames.isEmpty {
                    resolvedSection
                }
                if !model.unresolvedBarcodes.isEmpty {
                    unresolvedSection
                }
                if let message = model.errorMessage {
                    Text(message)
                        .rookFont(.subheadline)
                        .foregroundStyle(.red)
                        .padding(RookSpacing.m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .rookCard()
                }
            }
            .padding(.horizontal, RookSpacing.l)
            .padding(.vertical, RookSpacing.m)
        }
        .scrollContentBackground(.hidden)
    }

    private var viewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RookRadius.l, style: .continuous)
                .fill(Color.rookSurface)
                .frame(height: 220)
            VStack(spacing: RookSpacing.m) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 56))
                    .foregroundStyle(LinearGradient.rookBrand)
                Text(model.isScanning ? "Scanning…" : "Camera idle")
                    .rookFont(.subheadline)
                    .foregroundStyle(Color.rookForegroundSecondary)
                Text("Point at the back of the box. Detected barcodes will appear below.")
                    .rookFont(.caption)
                    .foregroundStyle(Color.rookForegroundTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RookSpacing.l)
            }
        }
    }

    private var resolvedSection: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text("Found")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            ForEach(model.resolvedGames) { game in
                HStack {
                    VStack(alignment: .leading, spacing: RookSpacing.xs) {
                        Text(game.name)
                            .rookFont(.headline)
                            .foregroundStyle(Color.rookForeground)
                        Text("\(game.playerRangeText) players · \(game.playtimeText)")
                            .rookFont(.caption)
                            .foregroundStyle(Color.rookForegroundSecondary)
                    }
                    Spacer()
                    Button {
                        model.remove(game)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.rookForegroundTertiary)
                    }
                }
                .rookCard()
            }
        }
    }

    private var unresolvedSection: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text("Unrecognized")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            ForEach(model.unresolvedBarcodes, id: \.self) { code in
                HStack {
                    Image(systemName: "questionmark.diamond")
                        .foregroundStyle(Color.rookForegroundTertiary)
                    Text(code)
                        .rookFont(.mono)
                        .foregroundStyle(Color.rookForegroundSecondary)
                    Spacer()
                }
                .rookCard()
            }
        }
    }
}
