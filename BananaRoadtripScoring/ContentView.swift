import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SessionViewModel
    @State private var showingResetConfirmation = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sessionHeader
                    playerControls
                    playerGrid
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.98, blue: 0.86), Color(red: 1.0, green: 0.92, blue: 0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Banana Roadtrip")
            .alert("Reset All Scores?", isPresented: $showingResetConfirmation) {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    viewModel.resetScores()
                }
            } message: {
                Text("This will set all players points back to zero.")
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Roadtrip")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Menu {
                    Button("Add Player", systemImage: "person.badge.plus") {
                        viewModel.addPlayer()
                    }
                    .disabled(!viewModel.canAddPlayer)

                    Menu("Remove Player", systemImage: "person.badge.minus") {
                        ForEach(viewModel.session.players) { player in
                            Button(player.name, systemImage: "person.fill") {
                                viewModel.removePlayer(id: player.id)
                            }
                            .disabled(!viewModel.canRemovePlayer)
                        }
                    }
                    .disabled(!viewModel.canRemovePlayer)

                    Button("Reset Scores", systemImage: "arrow.counterclockwise") {
                        showingResetConfirmation = true
                    }

                    Button("Fresh Trip", systemImage: "sparkles") {
                        viewModel.startFreshSession()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.brown)
                        .frame(width: 44, height: 44)
                }
            }

            TextField("Banana Roadtrip Name", text: Binding(
                get: { viewModel.session.name },
                set: viewModel.updateSessionName
            ))
            .font(.title2.weight(.bold))
            .padding()
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(20)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var playerControls: some View {
        HStack {
            Text("Riders")
                .font(.title3.weight(.bold))

            Spacer()

            Text("\(viewModel.session.players.count)/5")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private var playerGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.session.players) { player in
                PlayerCardView(
                    player: player,
                    emojiOptions: viewModel.emojiOptions,
                    isLeading: player.id == viewModel.leader?.id,
                    playerName: playerNameBinding(for: player.id),
                    onEmojiChange: { viewModel.updateEmoji(playerID: player.id, emoji: $0) },
                    onIncrement: { viewModel.incrementScore(for: player.id) },
                    onDecrement: { viewModel.decrementScore(for: player.id) }
                )
            }
        }
    }

    private func playerNameBinding(for playerID: UUID) -> Binding<String> {
        Binding(
            get: {
                viewModel.session.players.first(where: { $0.id == playerID })?.name ?? ""
            },
            set: { newValue in
                viewModel.updatePlayerName(playerID: playerID, name: newValue)
            }
        )
    }
}

#Preview {
    ContentView(viewModel: SessionViewModel())
}
