import SwiftUI

struct PlayerCardView: View {
    let player: Player
    let emojiOptions: [String]
    let isLeading: Bool
    let playerName: Binding<String>
    let onEmojiChange: (String) -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Menu {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button(emoji) {
                            onEmojiChange(emoji)
                        }
                    }
                } label: {
                    Text(player.emoji)
                        .font(.system(size: 44))
                        .frame(width: 72, height: 72)
                        .background(Color.yellow.opacity(0.25))
                        .clipShape(Circle())
                }

                Spacer()

                if isLeading {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color.orange.opacity(0.18))
                        .foregroundStyle(Color.orange)
                        .clipShape(Circle())
                }
            }

            TextField("Roadtripper Name", text: playerName)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .multilineTextAlignment(.center)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.yellow.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(spacing: 6) {
                Text("\(player.score)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text(player.score == 1 ? "banana point" : "banana points")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                Button(action: onDecrement) {
                    Label("Peel Slip", systemImage: "minus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 28))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(.orange)

                Button(action: onIncrement) {
                    Label("Banana Win", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 28))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow.opacity(0.9))
                .foregroundStyle(.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isLeading ? Color.orange.opacity(0.65) : Color.yellow.opacity(0.35), lineWidth: isLeading ? 3 : 2)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 6)
    }
}
