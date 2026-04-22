import SwiftUI

struct AppClipContentView: View {
    @Environment(\.colorScheme) private var colorScheme

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

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.white.opacity(0.78)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("BANANA!")
                    .font(.largeTitle.weight(.black))

                Text("Road Trip App Clip")
                    .font(.title3.weight(.bold))

                VStack(spacing: 12) {
                    Text("Quick Score Demo")
                        .font(.headline.weight(.semibold))

                    Text("Use the full app for the complete road trip scorekeeping experience.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                HStack(spacing: 12) {
                    quickStat(title: "Pink-a-licious", value: "+6")
                    quickStat(title: "Players", value: "2")
                }
            }
            .padding(24)
        }
    }

    private func quickStat(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title.weight(.bold))
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    AppClipContentView()
}
