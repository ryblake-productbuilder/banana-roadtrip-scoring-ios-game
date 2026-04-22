import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SessionViewModel
    @State private var showingResetConfirmation = false
    @State private var showingFreshTripConfirmation = false
    @State private var showingSettings = false
    @Environment(\.colorScheme) private var colorScheme

    private var usesCompactCards: Bool {
        viewModel.session.players.count >= 3
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: usesCompactCards ? 12 : 16),
            GridItem(.flexible(), spacing: usesCompactCards ? 12 : 16)
        ]
    }

    private var backgroundGradient: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.18, green: 0.14, blue: 0.05),
                Color(red: 0.32, green: 0.23, blue: 0.06)
            ]
        }

        return [
            Color(red: 1.0, green: 0.98, blue: 0.86),
            Color(red: 1.0, green: 0.92, blue: 0.55)
        ]
    }

    private var panelBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.white.opacity(0.72)
    }

    private var fieldBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.12)
            : Color.white.opacity(0.92)
    }

    private var accentTint: Color {
        colorScheme == .dark
            ? Color(red: 0.98, green: 0.82, blue: 0.33)
            : .brown
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    roadTripSection
                    playerControls
                    playerGrid
                    bonusPointsSection
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: backgroundGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Banana! Road Trip Scorekeeping")
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    overflowMenu
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheetView(viewModel: viewModel)
            }
            .alert("Reset All Scores?", isPresented: $showingResetConfirmation) {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    viewModel.resetScores()
                }
            } message: {
                Text("This will set all players points back to zero.")
            }
            .alert("Start Fresh Trip?", isPresented: $showingFreshTripConfirmation) {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    viewModel.startFreshSession()
                }
            } message: {
                Text("All players will be removed and this trip will be deleted.")
            }
        }
    }

    private var roadTripSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Road Trip:")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            TextField("Banana Roadtrip Name", text: Binding(
                get: { viewModel.session.name },
                set: viewModel.updateSessionName
            ))
            .font(.title2.weight(.bold))
            .foregroundStyle(.primary)
            .padding()
            .background(fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var overflowMenu: some View {
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
            .disabled(!viewModel.canResetScores)

            Button("Fresh Trip", systemImage: "sparkles") {
                showingFreshTripConfirmation = true
            }

            Button("Settings", systemImage: "gearshape.fill") {
                showingSettings = true
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(accentTint)
        }
    }

    private var playerControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Text("Players:")
                        .font(.title3.weight(.bold))

                    if viewModel.canAddPlayer {
                        Button {
                            viewModel.addPlayer()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(accentTint)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add Player")
                    }
                }

                Spacer()

                Text("\(viewModel.session.players.count)/6")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var playerGrid: some View {
        LazyVGrid(columns: columns, spacing: usesCompactCards ? 12 : 16) {
            ForEach(viewModel.session.players) { player in
                PlayerCardView(
                    player: player,
                    emojiOptions: viewModel.emojiOptions,
                    isLeading: player.id == viewModel.leader?.id,
                    compactLayout: usesCompactCards,
                    playerName: playerNameBinding(for: player.id),
                    onEmojiChange: { viewModel.updateEmoji(playerID: player.id, emoji: $0) },
                    onIncrement: { viewModel.incrementScore(for: player.id) },
                    onDecrement: { viewModel.decrementScore(for: player.id) }
                )
            }
        }
    }

    private var bonusPointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bonus Points:")
                .font(.title3.weight(.bold))

            HStack {
                Text("Pink-a-licious")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Menu(viewModel.session.players.isEmpty ? "Add Players First" : "Select Player") {
                    ForEach(viewModel.session.players) { player in
                        Button(player.name) {
                            viewModel.awardPinkALiciousPoints(to: player.id)
                        }
                    }
                }
                .font(.subheadline.weight(.semibold))
                .disabled(viewModel.session.players.isEmpty)
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
