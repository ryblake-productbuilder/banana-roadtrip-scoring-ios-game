import SwiftUI

struct PlayerCardView: View {
    let player: Player
    let emojiOptions: [String]
    let isLeading: Bool
    let compactLayout: Bool
    let playerName: Binding<String>
    let onEmojiChange: (String) -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(spacing: compactLayout ? 8 : 14) {
            HStack {
                Menu {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button(emoji) {
                            onEmojiChange(emoji)
                        }
                    }
                } label: {
                    Text(player.emoji)
                        .font(.system(size: compactLayout ? 28 : 40))
                        .frame(width: compactLayout ? 48 : 64, height: compactLayout ? 48 : 64)
                        .background(Color.yellow.opacity(0.25))
                        .clipShape(Circle())
                }

                Spacer()

                if isLeading {
                    Image(systemName: "crown.fill")
                        .font(.system(size: compactLayout ? 14 : 16, weight: .semibold))
                        .frame(width: compactLayout ? 26 : 32, height: compactLayout ? 26 : 32)
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
                .font(compactLayout ? .subheadline.weight(.semibold) : .headline)
                .padding(.horizontal, compactLayout ? 8 : 10)
                .padding(.vertical, compactLayout ? 6 : 8)
                .background(Color.yellow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(spacing: compactLayout ? 0 : 2) {
                Text("\(player.score)")
                    .font(.system(size: compactLayout ? 24 : 32, weight: .bold, design: .rounded))
            }

            HStack(spacing: compactLayout ? 8 : 10) {
                Button(action: onDecrement) {
                    Label("Peel Slip", systemImage: "minus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: compactLayout ? 20 : 24))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, compactLayout ? 6 : 8)
                }
                .buttonStyle(.bordered)
                .tint(.orange)

                Button(action: onIncrement) {
                    Label("Banana Win", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: compactLayout ? 20 : 24))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, compactLayout ? 6 : 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow.opacity(0.9))
                .foregroundStyle(.black)
            }
        }
        .padding(compactLayout ? 10 : 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isLeading ? Color.orange.opacity(0.65) : Color.yellow.opacity(0.35), lineWidth: isLeading ? 3 : 2)
        )
        .shadow(color: Color.black.opacity(0.06), radius: compactLayout ? 8 : 12, y: compactLayout ? 4 : 6)
    }
}
