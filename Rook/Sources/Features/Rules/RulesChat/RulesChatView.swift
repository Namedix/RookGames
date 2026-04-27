import SwiftUI

struct RulesChatView: View {
    @Bindable var model: RulesChatModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.rookBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    messages
                    composer
                }
            }
            .navigationTitle(model.game?.name ?? "Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { model.closeButtonTapped() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            model.clearHistoryButtonTapped()
                        } label: {
                            Label("Clear chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .toolbarBackground(Color.rookBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: RookSpacing.m) {
                    ForEach(model.messages) { message in
                        RulesMessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
            .onChange(of: model.messages.last?.id) { _, newID in
                guard let newID else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(newID, anchor: .bottom)
                }
            }
            .onChange(of: model.messages.last?.text) { _, _ in
                guard let id = model.messages.last?.id else { return }
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
    }

    private var composer: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.rookSeparator)
            HStack(alignment: .bottom, spacing: RookSpacing.s) {
                TextField("Ask a rules question…", text: $model.draft, axis: .vertical)
                    .textFieldStyle(.plain)
                    .rookFont(.body)
                    .foregroundStyle(Color.rookForeground)
                    .padding(RookSpacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous)
                            .fill(Color.rookSurface)
                    )
                    .lineLimit(1...5)

                Button {
                    model.sendButtonTapped()
                } label: {
                    Image(systemName: model.isStreaming ? "ellipsis" : "arrow.up")
                        .rookFont(.headline)
                        .foregroundStyle(Color.rookForeground)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle().fill(LinearGradient.rookBrand)
                        )
                }
                .disabled(!model.canSend)
                .opacity(model.canSend ? 1 : 0.5)
            }
            .padding(.horizontal, RookSpacing.l)
            .padding(.vertical, RookSpacing.m)
            .background(Color.rookBackground)
        }
    }
}

struct RulesMessageBubble: View {
    let message: RulesMessage

    var body: some View {
        HStack(alignment: .top, spacing: RookSpacing.s) {
            if message.role == .assistant {
                avatar
            } else {
                Spacer(minLength: RookSpacing.xxl)
            }

            VStack(alignment: message.role == .assistant ? .leading : .trailing, spacing: RookSpacing.xs) {
                Text(displayText)
                    .rookFont(.body)
                    .foregroundStyle(message.role == .assistant ? Color.rookForeground : Color.rookForeground)
                    .padding(RookSpacing.m)
                    .background(bubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: RookRadius.m, style: .continuous))
            }

            if message.role == .user {
                Spacer().frame(width: 0)
            } else {
                Spacer(minLength: RookSpacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .assistant ? .leading : .trailing)
    }

    private var displayText: String {
        if message.isStreaming && message.text.isEmpty {
            return "…"
        }
        return message.text
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if message.role == .assistant {
            Color.rookSurface
        } else {
            LinearGradient.rookBrand
        }
    }

    private var avatar: some View {
        Image(systemName: "sparkles")
            .rookFont(.subheadline)
            .foregroundStyle(LinearGradient.rookBrand)
            .frame(width: 28, height: 28)
            .background(
                Circle().fill(Color.rookSurfaceElevated)
            )
    }
}
