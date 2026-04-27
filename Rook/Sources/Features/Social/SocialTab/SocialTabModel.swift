import CasePaths
import Dependencies
import SwiftUI

@MainActor
@Observable
final class SocialTabModel {
    var path: [Path] {
        didSet { bind() }
    }
    var list: FriendsListModel {
        didSet { bind() }
    }

    @CasePathable
    @dynamicMemberLookup
    enum Path: Hashable {
        case friendDetail(FriendDetailModel)
        case search(SocialSearchModel)
    }

    init(
        path: [Path] = [],
        list: FriendsListModel = FriendsListModel()
    ) {
        self.path = path
        self.list = list
        self.bind()
    }

    private func bind() {
        list.onFriendTapped = { [weak self] friend in
            guard let self else { return }
            path.append(.friendDetail(FriendDetailModel(friend: friend)))
        }
        list.onSearchTapped = { [weak self] in
            guard let self else { return }
            path.append(.search(SocialSearchModel()))
        }
    }
}

extension SocialTabModel: Identifiable, Hashable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }

    nonisolated static func == (lhs: SocialTabModel, rhs: SocialTabModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
