import Foundation

struct AppSettings: Codable, Equatable {
    var pinkALiciousPoints: Int

    static func `default`() -> AppSettings {
        AppSettings(pinkALiciousPoints: 6)
    }
}
