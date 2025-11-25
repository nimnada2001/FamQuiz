//
//  GameOverView.swift
//  Multi-User Family Quiz Arena
//
//  Game over screen showing final leaderboard and results
//  Includes victory animations and options to replay or return to menu
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfetti = false
    @State private var animateLeaderboard = false

    var body: some View {
        ZStack {
            // Celebratory background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.75, blue: 0.18),   // gold
                    Color(red: 0.93, green: 0.49, blue: 0.28),   // orange
                    Color(red: 0.76, green: 0.33, blue: 0.79)    // purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti effect
            if showConfetti {
                ConfettiView()
            }

            VStack(spacing: 50) {
                // Header
                VStack(spacing: 25) {
                    Text("🏆")
                        .font(.system(size: 130))
                        .scaleEffect(animateLeaderboard ? 1.0 : 0.5)
                        .opacity(animateLeaderboard ? 1.0 : 0.0)
                        .shadow(color: .yellow.opacity(0.8), radius: 30, x: 0, y: 12)

                    Text("Game Over!")
                        .font(.system(size: 72, weight: .heavy))
                        .foregroundColor(.white)
                        .scaleEffect(animateLeaderboard ? 1.0 : 0.5)
                        .opacity(animateLeaderboard ? 1.0 : 0.0)
                        .shadow(color: .black.opacity(0.5), radius: 26, x: 0, y: 14)

                    Text("Final Results")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(animateLeaderboard ? 1.0 : 0.0)
                }
                .padding(.top, 60)

                // Leaderboard
                LeaderboardView(players: viewModel.players, animated: animateLeaderboard)
                    .padding(.horizontal, 100)

                // Action buttons
                HStack(spacing: 40) {
                    // Play Again button
                    ActionButton(
                        title: "Play Again",
                        icon: "arrow.clockwise.circle.fill",
                        color: .green
                    ) {
                        SoundManager.shared.playButtonTap()
                        viewModel.restartGame()
                    }

                    // Main Menu button
                    ActionButton(
                        title: "Main Menu",
                        icon: "house.circle.fill",
                        color: .blue
                    ) {
                        SoundManager.shared.playButtonTap()
                        viewModel.returnToMenu()
                    }
                }
                .padding(.bottom, 60)
                .opacity(animateLeaderboard ? 1.0 : 0.0)
            }
        }
        .onAppear {
            // Trigger animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateLeaderboard = true
            }

            // Show confetti after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Leaderboard View

struct LeaderboardView: View {
    let players: [Player]
    let animated: Bool

    var body: some View {
        let maxScore = players.first?.score ?? 0
        VStack(spacing: 20) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                LeaderboardRow(
                    player: player,
                    rank: index + 1,
                    totalPlayers: players.count,
                    maxScore: maxScore
                )
                .offset(x: animated ? 0 : 1000)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                    value: animated
                )
            }
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let player: Player
    let rank: Int
    let totalPlayers: Int
    let maxScore: Int

    private var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .white.opacity(0.7)
        }
    }

    private var backgroundOpacity: Double {
        switch rank {
        case 1: return 0.3
        case 2: return 0.2
        case 3: return 0.15
        default: return 0.1
        }
    }

    var body: some View {
        HStack(spacing: 30) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.3))
                    .frame(width: 80, height: 80)

                if rank <= 3 {
                    Text(medalEmoji)
                        .font(.system(size: 50))
                } else {
                    Text("\(rank)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // Avatar
            Text(player.avatar)
                .font(.system(size: 60))

            // Player info
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text("\(player.score) points")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.yellow)
            }

            Spacer()

            // Score bar
            ScoreBar(score: player.score, maxScore: maxScore)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                rankColor.opacity(backgroundOpacity + 0.1),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 24)
                    .stroke(rank == 1 ? Color.white : rankColor.opacity(0.9), lineWidth: rank == 1 ? 4 : 2)
            }
        )
        .scaleEffect(rank == 1 ? 1.06 : 1.0)
        .shadow(color: rank == 1 ? rankColor.opacity(0.55) : .black.opacity(0.35), radius: 22, x: 0, y: 14)
    }
}

// MARK: - Score Bar

struct ScoreBar: View {
    let score: Int
    let maxScore: Int

    private var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore)
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("\(Int(percentage * 100))%")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.white)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 20)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.yellow, .orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200 * percentage, height: 20)
                }
            }
            .frame(width: 200, height: 20)
        }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 40))

                Text(title)
                    .font(.system(size: 38, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 50)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(color.opacity(isFocused ? 1.0 : 0.7))
            )
            .scaleEffect(isFocused ? 1.08 : 1.0)
            .shadow(color: color.opacity(isFocused ? 0.6 : 0.3), radius: isFocused ? 25 : 12)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiShape(color: piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            generateConfetti()
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [.red, .yellow, .green, .blue, .purple, .pink, .orange]

        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: Double.random(in: 0...1920),
                y: Double.random(in: -100...0),
                color: colors.randomElement() ?? .yellow,
                size: Double.random(in: 10...30),
                rotation: Double.random(in: 0...360),
                opacity: Double.random(in: 0.6...1.0)
            )
            confettiPieces.append(piece)

            // Animate each piece
            withAnimation(.linear(duration: Double.random(in: 3...6)).repeatForever(autoreverses: false)) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].y = 1080 + 100
                    confettiPieces[index].rotation += 360
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    let color: Color
    let size: Double
    var rotation: Double
    var opacity: Double
}

struct ConfettiShape: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
    }
}

// MARK: - Preview

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GameViewModel()
        viewModel.addTestPlayer(name: "Alex", avatar: "🦊")
        viewModel.addTestPlayer(name: "Sam", avatar: "🐻")
        viewModel.addTestPlayer(name: "Jordan", avatar: "🦁")
        viewModel.players[0].score = 850
        viewModel.players[1].score = 600
        viewModel.players[2].score = 450

        return GameOverView(viewModel: viewModel)
    }
}
