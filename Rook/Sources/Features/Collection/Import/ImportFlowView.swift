import SwiftUI
import SwiftUINavigation

struct ImportFlowView: View {
    @Bindable var model: ImportFlowModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.rookBackground.ignoresSafeArea()
                methodPicker
            }
            .navigationTitle("Add games")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { model.cancelButtonTapped() }
                }
            }
            .toolbarBackground(Color.rookBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(item: $model.destination.search) { childModel in
                ImportSearchView(model: childModel)
            }
            .navigationDestination(item: $model.destination.barcode) { childModel in
                ImportBarcodeView(model: childModel)
            }
            .navigationDestination(item: $model.destination.photo) { childModel in
                ImportPhotoView(model: childModel)
            }
        }
    }

    private var methodPicker: some View {
        VStack(spacing: RookSpacing.m) {
            methodCard(
                method: .photo,
                title: "Photo of your shelf",
                subtitle: "AI scans the image and suggests every game it sees.",
                icon: "photo.on.rectangle.angled"
            )
            methodCard(
                method: .barcode,
                title: "Scan a barcode",
                subtitle: "Point your camera at the back of the box.",
                icon: "barcode.viewfinder"
            )
            methodCard(
                method: .search,
                title: "Search the catalog",
                subtitle: "Type a name and pick from results.",
                icon: "magnifyingglass"
            )
            Spacer()
        }
        .padding(.horizontal, RookSpacing.l)
        .padding(.top, RookSpacing.l)
    }

    private func methodCard(
        method: ImportFlowModel.Method,
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {
        Button {
            model.methodSelected(method)
        } label: {
            HStack(spacing: RookSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(LinearGradient.rookBrand)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous)
                            .fill(LinearGradient.rookBrand.opacity(0.18))
                    )
                VStack(alignment: .leading, spacing: RookSpacing.xs) {
                    Text(title)
                        .rookFont(.headline)
                        .foregroundStyle(Color.rookForeground)
                    Text(subtitle)
                        .rookFont(.subheadline)
                        .foregroundStyle(Color.rookForegroundSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .rookFont(.footnote)
                    .foregroundStyle(Color.rookForegroundTertiary)
            }
            .rookCard()
        }
        .buttonStyle(.plain)
    }
}
