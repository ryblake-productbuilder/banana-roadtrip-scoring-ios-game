import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var session: RoadTripSession {
        didSet {
            save()
        }
    }

    let emojiOptions = ["🍌", "🚐", "🛣️", "🌴", "🐒", "⭐", "🎒", "🥤", "☀️", "🏁"]

    private let saveURL: URL

    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        self.saveURL = documentsDirectory?
            .appendingPathComponent("banana-roadtrip-session.json")
            ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("banana-roadtrip-session.json")

        self.session = Self.loadSession(from: saveURL) ?? .default()
    }

    var canAddPlayer: Bool {
        session.players.count < 5
    }

    var canRemovePlayer: Bool {
        session.players.count > 1
    }

    var leader: Player? {
        session.players.max(by: { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
            }

            return lhs.score < rhs.score
        })
    }

    var totalScore: Int {
        session.players.reduce(0) { $0 + $1.score }
    }

    func updateSessionName(_ name: String) {
        session.name = name
    }

    func updatePlayerName(playerID: UUID, name: String) {
        guard let index = indexForPlayer(id: playerID) else { return }
        session.players[index].name = name
    }

    func updateEmoji(playerID: UUID, emoji: String) {
        guard let index = indexForPlayer(id: playerID) else { return }
        session.players[index].emoji = emoji
    }

    func incrementScore(for playerID: UUID) {
        guard let index = indexForPlayer(id: playerID) else { return }
        session.players[index].score += 1
    }

    func decrementScore(for playerID: UUID) {
        guard let index = indexForPlayer(id: playerID) else { return }
        session.players[index].score -= 1
    }

    func addPlayer() {
        guard canAddPlayer else { return }

        let nextNumber = session.players.count + 1
        let emoji = emojiOptions[(nextNumber - 1) % emojiOptions.count]
        session.players.append(Player(name: "Banana Buddy \(nextNumber)", emoji: emoji))
    }

    func removePlayer(id: UUID) {
        guard canRemovePlayer else { return }
        guard let index = indexForPlayer(id: id) else { return }
        session.players.remove(at: index)
    }

    func resetScores() {
        for index in session.players.indices {
            session.players[index].score = 0
        }
    }

    func startFreshSession() {
        let existingPlayers = session.players.enumerated().map { offset, player in
            Player(name: player.name, emoji: player.emoji, score: 0)
        }

        session = RoadTripSession(
            name: "Banana Dash \(Date.now.formatted(date: .abbreviated, time: .omitted))",
            players: existingPlayers
        )
    }

    private func indexForPlayer(id: UUID) -> Int? {
        session.players.firstIndex(where: { $0.id == id })
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: saveURL, options: [.atomic])
        } catch {
            print("Failed to save session: \(error.localizedDescription)")
        }
    }

    private static func loadSession(from url: URL) -> RoadTripSession? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(RoadTripSession.self, from: data)
        } catch {
            return nil
        }
    }
}
