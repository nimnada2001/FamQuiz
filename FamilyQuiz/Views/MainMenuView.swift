//
//  MainMenuView.swift
//  Multi-User Family Quiz Arena
//
//  Main menu screen with navigation to game modes and history
//  Optimized for tvOS Focus Engine with large touch targets
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showHistory = false

    var body: some View {
        ZStack {
            // Vibrant animated background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.64, blue: 0.16),   // warm orange
                    Color(red: 0.90, green: 0.30, blue: 0.50),   // pink
                    Color(red: 0.32, green: 0.42, blue: 0.96)    // indigo
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 60) {
                // Title section
                VStack(spacing: 20) {
                    Text("🇱🇰")
                        .font(.system(size: 120))
                        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)

                    Text("Sri Lankan Quiz")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.yellow.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.45), radius: 25, x: 0, y: 14)

                    Text("Test your knowledge about Sri Lanka!")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 80)

                // Menu buttons
                VStack(spacing: 30) {
                    // Start Game button
                    MenuButton(
                        title: "Start New Game",
                        icon: "play.circle.fill",
                        color: .green
                    ) {
                        SoundManager.shared.playButtonTap()
                        viewModel.startHosting()
                    }

                    // Game History button
                    MenuButton(
                        title: "Game History",
                        icon: "clock.arrow.circlepath",
                        color: .purple
                    ) {
                        SoundManager.shared.playButtonTap()
                        showHistory = true
                    }

                    // Settings button
                    MenuButton(
                        title: "Settings",
                        icon: "gear",
                        color: .blue
                    ) {
                        SoundManager.shared.playButtonTap()
                        // Settings view would go here
                    }
                }
                .padding(.horizontal, 100)

                Spacer()

                // Footer
                Text("Use iPhone or Siri Remote to play")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.gameState == .lobby },
            set: { if !$0 { viewModel.returnToMenu() } }
        )) {
            LobbyView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.gameState == .countdown || viewModel.gameState == .playing || viewModel.gameState == .questionResult },
            set: { _ in }
        )) {
            GamePlayView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.gameState == .gameOver },
            set: { _ in }
        )) {
            GameOverView(viewModel: viewModel)
        }
        .sheet(isPresented: $showHistory) {
            GameHistoryView()
        }
    }
}

// MARK: - Menu Button Component

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 25) {
                Image(systemName: icon)
                    .font(.system(size: 45))
                    .foregroundColor(.white)
                    .frame(width: 60)

                Text(title)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 35)
            .background(
                ZStack {
                    // Outer glow
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 10)

                    // Main button
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(isFocused ? 0.95 : 0.8),
                                    Color.white.opacity(isFocused ? 0.3 : 0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.9), Color.white.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isFocused ? 4 : 2
                                )
                        )
                }
            )
            .scaleEffect(isFocused ? 1.06 : 1.0)
            .shadow(color: color.opacity(isFocused ? 0.7 : 0.35), radius: isFocused ? 32 : 16, x: 0, y: 18)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Preview

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
