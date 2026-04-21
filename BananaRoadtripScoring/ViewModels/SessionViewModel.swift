import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var session: RoadTripSession {
        didSet {
            save()
        }
    }
    @Published private(set) var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }

    let emojiOptions = ["🍌", "🚐", "🛣️", "🌴", "🐒", "⭐", "🎒", "🥤", "☀️", "🏁"]

    private let saveURL: URL
    private let settingsURL: URL

    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        self.saveURL = documentsDirectory?
            .appendingPathComponent("banana-roadtrip-session.json")
            ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("banana-roadtrip-session.json")
        self.settingsURL = documentsDirectory?
            .appendingPathComponent("banana-roadtrip-settings.json")
            ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("banana-roadtrip-settings.json")

        self.session = Self.loadSession(from: saveURL) ?? .default()
        self.settings = Self.loadSettings(from: settingsURL) ?? .default()
    }

    var canAddPlayer: Bool {
        session.players.count < 6
    }

    var canRemovePlayer: Bool {
        session.players.count > 1
    }

    var canResetScores: Bool {
        session.players.contains(where: { $0.score != 0 })
    }

    var leader: Player? {
        guard let highestScore = session.players.map(\.score).max() else {
            return nil
        }

        let leaders = session.players.filter { $0.score == highestScore }
        guard leaders.count == 1 else {
            return nil
        }

        return leaders.first
    }

    var totalScore: Int {
        session.players.reduce(0) { $0 + $1.score }
    }

    func updateSessionName(_ name: String) {
        session.name = name
    }

    func updateSettings(_ updatedSettings: AppSettings) {
        settings = updatedSettings
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

    func awardPinkALiciousPoints(to playerID: UUID) {
        guard let index = indexForPlayer(id: playerID) else { return }
        session.players[index].score += settings.pinkALiciousPoints
    }

    func startFreshSession() {
        session = RoadTripSession(
            name: "",
            players: []
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

    private func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsURL, options: [.atomic])
        } catch {
            print("Failed to save settings: \(error.localizedDescription)")
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

    private static func loadSettings(from url: URL) -> AppSettings? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return nil
        }
    }
}
