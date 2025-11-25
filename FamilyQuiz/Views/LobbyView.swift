//
//  LobbyView.swift
//  Multi-User Family Quiz Arena
//
//  Lobby screen where players join before game starts
//  Shows connected players and waiting for players to join
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: GameViewModel
    @FocusState private var startButtonFocused: Bool

    var body: some View {
        ZStack {
            // Colorful lobby background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.14, green: 0.54, blue: 0.96),   // blue
                    Color(red: 0.39, green: 0.80, blue: 0.87),   // teal
                    Color(red: 0.96, green: 0.77, blue: 0.37)    // gold
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 50) {
                // Header
                VStack(spacing: 20) {
                    Text("🎮")
                        .font(.system(size: 110))
                        .shadow(color: .black.opacity(0.3), radius: 18, x: 0, y: 10)

                    Text("Game Lobby")
                        .font(.system(size: 62, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 22, x: 0, y: 12)

                    Text("Waiting for players to join...")
                        .font(.system(size: 34))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 60)

                // Players grid
                if viewModel.players.isEmpty {
                    VStack(spacing: 30) {
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 120))
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 10)

                        Text("No players connected yet")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Connect via iPhone or add test players")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 30) {
                            ForEach(viewModel.players) { player in
                                PlayerCard(player: player)
                            }
                        }
                        .padding(.horizontal, 80)
                    }
                }

                // Action buttons
                HStack(spacing: 40) {
                    // Add test player button
                    Button(action: {
                        SoundManager.shared.playPlayerJoin()
                        let avatars = ["🦊", "🐻", "🦁", "🐯", "🐼", "🐨", "🐸", "🐙"]
                        let names = ["Alex", "Sam", "Jordan", "Casey", "Morgan", "Riley", "Quinn", "Taylor"]
                        let randomAvatar = avatars.randomElement() ?? "👤"
                        let randomName = names.randomElement() ?? "Player"
                        viewModel.addTestPlayer(name: randomName, avatar: randomAvatar)
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 35))
                            Text("Add Test Player")
                                .font(.system(size: 35, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 45)
                        .padding(.vertical, 30)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.85), Color.cyan.opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.blue.opacity(0.55), radius: 18, x: 0, y: 12)

                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Start game button
                    Button(action: {
                        SoundManager.shared.playGameStart()
                        viewModel.startGame()
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 35))
                            Text("Start Game")
                                .font(.system(size: 35, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 30)
                        .background(
                            ZStack {
                                let active = !viewModel.players.isEmpty
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: active
                                            ? [Color.green.opacity(0.9), Color.mint.opacity(0.9)]
                                            : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: (active ? Color.green : Color.gray).opacity(0.6), radius: 20, x: 0, y: 12)

                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(active ? 0.9 : 0.4), lineWidth: active ? 3 : 2)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.players.isEmpty)
                    .focused($startButtonFocused)

                    // Cancel button
                    Button(action: {
                        SoundManager.shared.playButtonTap()
                        viewModel.returnToMenu()
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 35))
                            Text("Cancel")
                                .font(.system(size: 35, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 45)
                        .padding(.vertical, 30)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.9), Color.orange.opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.red.opacity(0.6), radius: 18, x: 0, y: 12)

                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 60)
            }

            // Pulsing connection indicator
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 15) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.cyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 22, height: 22)
                            .shadow(color: Color.green.opacity(0.8), radius: 10)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 1.0).repeatForever(), value: UUID())

                        Text("Hosting")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                            )
                    )
                    .padding(.trailing, 50)
                }
                .padding(.top, 50)

                Spacer()
            }
        }
    }
}

// MARK: - Player Card Component

struct PlayerCard: View {
    let player: Player

    var body: some View {
        VStack(spacing: 20) {
            Text(player.avatar)
                .font(.system(size: 80))

            Text(player.name)
                .font(.system(size: 35, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                Circle()
                    .fill(player.isConnected ? Color.green : Color.gray)
                    .frame(width: 15, height: 15)

                Text(player.isConnected ? "Connected" : "Disconnected")
                    .font(.system(size: 25))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.45), lineWidth: 2)
            }
        )
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 12)
    }
}

// MARK: - Preview

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GameViewModel()
        viewModel.addTestPlayer(name: "Alex", avatar: "🦊")
        viewModel.addTestPlayer(name: "Sam", avatar: "🐻")
        viewModel.addTestPlayer(name: "Jordan", avatar: "🦁")

        return LobbyView(viewModel: viewModel)
    }
}
