import Dependencies
import IdentifiedCollections
import Sharing
import SwiftUI

@MainActor
@Observable
final class RulesChatModel {
    let gameID: Game.ID

    var draft = ""
    var isStreaming = false
    var errorMessage: String?

    @ObservationIgnored @Shared(.collection) var collection
    @ObservationIgnored @Shared(.rulesThreads) var threads

    @ObservationIgnored @Dependency(\.rulesChat) var rulesChat
    @ObservationIgnored @Dependency(\.uuid) var uuid
    @ObservationIgnored @Dependency(\.date.now) var now

    var onClose: () -> Void = {}

    private var streamTask: Task<Void, Never>?

    init(gameID: Game.ID) {
        self.gameID = gameID
        seedThreadIfNeeded()
    }

    var game: Game? { collection[id: gameID] }

    var thread: RulesThread {
        threads[id: gameID] ?? RulesThread(gameID: gameID)
    }

    var messages: IdentifiedArrayOf<RulesMessage> {
        thread.messages
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }

    private func seedThreadIfNeeded() {
        guard threads[id: gameID] == nil else { return }
        let intro = RulesMessage(
            id: RulesMessage.ID(uuid()),
            role: .assistant,
            text: introText,
            createdAt: now
        )
        $threads.withLock {
            $0.append(RulesThread(gameID: gameID, messages: [intro]))
        }
    }

    private var introText: String {
        if let name = game?.name {
            return "Hi! I'm trained on the \(name) rulebook. Ask me anything — setup, edge cases, end-of-game scoring."
        }
        return "Hi! Ask me anything about this game's rules."
    }

    func sendButtonTapped() {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isStreaming else { return }

        let userMessage = RulesMessage(
            id: RulesMessage.ID(uuid()),
            role: .user,
            text: prompt,
            createdAt: now
        )
        let assistantID = RulesMessage.ID(uuid())
        let assistantPlaceholder = RulesMessage(
            id: assistantID,
            role: .assistant,
            text: "",
            createdAt: now,
            isStreaming: true
        )

        $threads.withLock { threads in
            var thread = threads[id: gameID] ?? RulesThread(gameID: gameID)
            thread.messages.append(userMessage)
            thread.messages.append(assistantPlaceholder)
            threads[id: gameID] = thread
        }

        draft = ""
        errorMessage = nil
        isStreaming = true

        let history = Array(thread.messages.dropLast(2))
        streamTask?.cancel()
        streamTask = Task { [weak self, gameID] in
            guard let self else { return }
            do {
                for try await chunk in rulesChat.streamReply(
                    gameID: gameID,
                    history: history,
                    prompt: prompt
                ) {
                    if Task.isCancelled { break }
                    appendChunk(chunk, to: assistantID)
                }
                finalize(assistantID, error: nil)
            } catch {
                finalize(assistantID, error: error)
            }
        }
    }

    private func appendChunk(_ chunk: String, to id: RulesMessage.ID) {
        $threads.withLock { threads in
            guard var thread = threads[id: gameID] else { return }
            guard var message = thread.messages[id: id] else { return }
            message.text += chunk
            thread.messages[id: id] = message
            threads[id: gameID] = thread
        }
    }

    private func finalize(_ id: RulesMessage.ID, error: Error?) {
        $threads.withLock { threads in
            guard var thread = threads[id: gameID] else { return }
            guard var message = thread.messages[id: id] else { return }
            message.isStreaming = false
            if let error {
                message.text = message.text.isEmpty
                    ? "Sorry, something went wrong."
                    : message.text
                _ = error
            }
            thread.messages[id: id] = message
            threads[id: gameID] = thread
        }
        if let error { errorMessage = error.localizedDescription }
        isStreaming = false
    }

    func clearHistoryButtonTapped() {
        streamTask?.cancel()
        $threads.withLock { threads in
            threads[id: gameID] = nil
        }
        seedThreadIfNeeded()
    }

    func closeButtonTapped() {
        streamTask?.cancel()
        onClose()
    }
}

extension RulesChatModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: RulesChatModel, rhs: RulesChatModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
