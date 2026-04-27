import Dependencies
import DependenciesMacros
import Foundation

/// Surface for the eventual auth backend. While this is mocked the app
/// always treats the user as signed in as ``User.mockMe``; the sign-in /
/// sign-out screens land alongside the real backend.
@DependencyClient
struct AuthClient: Sendable {
    var currentUser: @Sendable () async throws -> User
    var signIn: @Sendable (_ handle: String) async throws -> User
    var signOut: @Sendable () async throws -> Void
}

extension AuthClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.mock
}

extension DependencyValues {
    var auth: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

extension AuthClient: DependencyKey {
    static let liveValue: Self = .mock
}

extension AuthClient {
    static let mock: Self = {
        Self(
            currentUser: { .mockMe },
            signIn: { handle in
                try await Task.sleep(nanoseconds: 300_000_000)
                return User(
                    id: User.mockMe.id,
                    handle: handle,
                    displayName: handle.capitalized
                )
            },
            signOut: {
                try await Task.sleep(nanoseconds: 200_000_000)
            }
        )
    }()
}
