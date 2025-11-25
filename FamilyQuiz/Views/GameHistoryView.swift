//
//  GameHistoryView.swift
//  Multi-User Family Quiz Arena
//
//  View showing past game sessions and scores from Core Data
//  Allows users to review previous games and performance
//

import SwiftUI
import CoreData

struct GameHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GameSession.date, ascending: false)],
        animation: .default)
    private var gameSessions: FetchedResults<GameSession>

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.11, green: 0.32, blue: 0.76),   // blue
                    Color(red: 0.39, green: 0.61, blue: 0.94),   // light blue
                    Color(red: 0.94, green: 0.72, blue: 0.33)    // warm gold
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                HStack {
                    Button(action: {
                        SoundManager.shared.playButtonTap()
                        dismiss()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 40))
                            Text("Back")
                                .font(.system(size: 35, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    VStack(spacing: 10) {
                        Text("📊")
                            .font(.system(size: 60))

                        Text("Game History")
                            .font(.system(size: 50, weight: .heavy))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
                    }

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear.frame(width: 150)
                }
                .padding(.horizontal, 80)
                .padding(.top, 50)

                // Game sessions list
                if gameSessions.isEmpty {
                    VStack(spacing: 30) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.4), radius: 18, x: 0, y: 10)

                        Text("No games played yet")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Start a new game to see results here")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 25) {
                            ForEach(gameSessions) { session in
                                GameSessionCard(session: session)
                            }
                        }
                        .padding(.horizontal, 80)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}

// MARK: - Game Session Card

struct GameSessionCard: View {
    let session: GameSession
    @State private var isExpanded = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private var sortedResults: [PlayerResult] {
        let results = session.playerResults?.allObjects as? [PlayerResult] ?? []
        return results.sorted { $0.score > $1.score }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Card header
            Button(action: {
                withAnimation(.spring(response: 0.4)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 25) {
                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.date ?? Date(), formatter: dateFormatter)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 15) {
                            Label("\(session.numberOfPlayers) players", systemImage: "person.2.fill")
                            Label("\(session.numberOfQuestions) questions", systemImage: "questionmark.circle.fill")
                        }
                        .font(.system(size: 25))
                        .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    // Winner info
                    if let winner = sortedResults.first {
                        HStack(spacing: 15) {
                            Text("Winner:")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.8))

                            if let avatar = winner.avatar {
                                Text(avatar)
                                    .font(.system(size: 40))
                            }

                            Text(winner.playerName ?? "Unknown")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.yellow)

                            Text("\(winner.score) pts")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 30)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded details
            if isExpanded {
                VStack(spacing: 15) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal, 40)

                    ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, result in
                        HistoryPlayerRow(result: result, rank: index + 1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.26), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.45), lineWidth: 2)
            }
        )
        .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 12)
    }
}

// MARK: - History Player Row

struct HistoryPlayerRow: View {
    let result: PlayerResult
    let rank: Int

    private var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }

    var body: some View {
        HStack(spacing: 20) {
            // Rank
            Text(medalEmoji)
                .font(.system(size: rank <= 3 ? 35 : 28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60)

            // Avatar
            if let avatar = result.avatar {
                Text(avatar)
                    .font(.system(size: 35))
            }

            // Name
            Text(result.playerName ?? "Unknown")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            // Stats
            HStack(spacing: 30) {
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Score")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(result.score)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.yellow)
                }

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Correct")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(result.correctAnswers)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

struct GameHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        GameHistoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
