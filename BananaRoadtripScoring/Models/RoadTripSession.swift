import Foundation

struct RoadTripSession: Codable, Equatable {
    var name: String
    var players: [Player]

    static func `default`() -> RoadTripSession {
        RoadTripSession(
            name: "Banana Dash",
            players: [
                Player(name: "Scout Banana", emoji: "🍌"),
                Player(name: "Peel Racer", emoji: "🚐")
            ]
        )
    }
}
