import IdentifiedCollections
import Sharing
import SwiftUI
import SwiftUINavigation

struct CountersListView: View {
    @Bindable var model: CountersListModel

    var body: some View {
        List {
            if model.counters.isEmpty {
                ContentUnavailableView {
                    Label("No counters yet", systemImage: "number.circle")
                } description: {
                    Text("Tap + to start tracking something.")
                }
            } else {
                ForEach(Array(model.$counters)) { $counter in
                    Button {
                        model.onCounterTapped($counter)
                    } label: {
                        CounterRow(counter: counter)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    model.deleteCounters(at: offsets)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Counters")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.addCounterButtonTapped()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $model.addCounter) { formModel in
            NavigationStack {
                CounterFormView(model: formModel)
                    .navigationTitle("New counter")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") { model.dismissAddCounterButtonTapped() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") { model.confirmAddCounterButtonTapped() }
                                .disabled(formModel.counter.name.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
            }
        }
    }
}

private struct CounterRow: View {
    let counter: Counter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(counter.name.isEmpty ? "Untitled" : counter.name)
                    .font(.headline)
                Text(counter.createdAt, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(counter.value)")
                .font(.title2.monospacedDigit())
                .foregroundStyle(.tint)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview("With data") {
    NavigationStack {
        CountersListView(model: CountersListModel())
    }
}

#Preview("Empty") {
    @Shared(.counters) var counters: IdentifiedArrayOf<Counter> = []
    NavigationStack {
        CountersListView(model: CountersListModel())
    }
}
