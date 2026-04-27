import SwiftUI

struct CounterFormView: View {
    @Bindable var model: CounterFormModel
    @FocusState private var focus: CounterFormModel.Field?

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $model.counter.name)
                    .focused($focus, equals: .name)
                    .submitLabel(.done)
            }
            Section("Starting value") {
                Stepper(value: $model.counter.value) {
                    Text("\(model.counter.value)")
                        .monospacedDigit()
                }
            }
        }
        .bind($model.focus, to: $focus)
    }
}

#Preview {
    NavigationStack {
        CounterFormView(model: CounterFormModel(counter: .mock))
    }
}
