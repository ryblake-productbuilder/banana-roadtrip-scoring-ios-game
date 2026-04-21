import SwiftUI

@main
struct BananaRoadtripScoringApp: App {
    @StateObject private var viewModel = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
