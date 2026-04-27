import Dependencies
import Foundation

/// Surface for the eventual rules-aware chat backend (RAG over a per-game
/// rulebook corpus, served by an LLM provider). Today the mock yields a few
/// canned tokens so the streaming UI can be exercised end-to-end.
///
/// Written without `@DependencyClient` because that macro currently generates
/// a synthesized `unimplemented` body that returns `.finished` (a property
/// on `AsyncStream`) — which doesn't compile for `AsyncThrowingStream` whose
/// `finished(throwing:)` is a static method.
struct RulesChatClient: Sendable {
    var streamReply: @Sendable (
        _ gameID: Game.ID,
        _ history: [RulesMessage],
        _ prompt: String
    ) -> AsyncThrowingStream<String, Error> = { _, _, _ in
        AsyncThrowingStream { $0.finish() }
    }

    func streamReply(
        gameID: Game.ID,
        history: [RulesMessage],
        prompt: String
    ) -> AsyncThrowingStream<String, Error> {
        self.streamReply(gameID, history, prompt)
    }
}

extension RulesChatClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.mock
}

extension DependencyValues {
    var rulesChat: RulesChatClient {
        get { self[RulesChatClient.self] }
        set { self[RulesChatClient.self] = newValue }
    }
}

extension RulesChatClient: DependencyKey {
    static let liveValue: Self = .mock
}

extension RulesChatClient {
    static let mock: Self = {
        Self(
            streamReply: { _, _, prompt in
                AsyncThrowingStream { continuation in
                    let task = Task {
                        let response = mockResponse(for: prompt)
                        let chunks = response.split(separator: " ").map { String($0) }
                        for (index, chunk) in chunks.enumerated() {
                            if Task.isCancelled { break }
                            try await Task.sleep(nanoseconds: 60_000_000)
                            let prefix = index == 0 ? "" : " "
                            continuation.yield(prefix + chunk)
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            }
        )
    }()

    private static func mockResponse(for prompt: String) -> String {
        let lowered = prompt.lowercased()
        if lowered.contains("setup") {
            return "To set up: shuffle the main deck, deal each player a starting hand of three cards, and place the round tracker on space one. Each player picks a starting role and takes the matching board."
        }
        if lowered.contains("score") || lowered.contains("points") {
            return "Scoring happens at the end of the final round. Sum end-game bonuses, subtract penalties for unused resources, and the highest total wins. Ties are broken by remaining cards in hand."
        }
        if lowered.contains("turn") || lowered.contains("action") {
            return "On your turn, take exactly one main action: gather, build, or trade. Then resolve any triggered abilities and pass to the player on your left."
        }
        return "Great question — here is the relevant rule. Each round consists of a planning phase followed by an action phase. During planning, secretly choose your card; during action, reveal simultaneously and resolve in initiative order."
    }
}
