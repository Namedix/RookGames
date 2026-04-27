import IdentifiedCollections
import Sharing
import SwiftUI
import SwiftUINavigation

struct CounterDetailView: View {
    @Bindable var model: CounterDetailModel

    var body: some View {
        Form {
            Section("Value") {
                HStack {
                    Spacer()
                    Text("\(model.counter.value)")
                        .font(.system(size: 64, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Spacer()
                }
                HStack(spacing: 12) {
                    Button {
                        model.decrementButtonTapped()
                    } label: {
                        Label("Decrement", systemImage: "minus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        model.incrementButtonTapped()
                    } label: {
                        Label("Increment", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                Button("Reset", role: .destructive) {
                    model.resetButtonTapped()
                }
            }

            Section {
                Button("Delete counter", role: .destructive) {
                    model.deleteButtonTapped()
                }
            }
        }
        .navigationTitle(model.counter.name.isEmpty ? "Counter" : model.counter.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    model.editButtonTapped()
                }
            }
        }
        .alert($model.destination.alert) { action in
            model.alertButtonTapped(action)
        }
        .sheet(item: $model.destination.edit) { editModel in
            NavigationStack {
                CounterFormView(model: editModel)
                    .navigationTitle("Edit counter")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { model.cancelEditButtonTapped() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { model.doneEditingButtonTapped() }
                        }
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        @Shared(.counters) var counters: IdentifiedArrayOf<Counter> = [.mock]
        CounterDetailView(
            model: CounterDetailModel(counter: Shared($counters[id: Counter.mock.id])!)
        )
    }
}
