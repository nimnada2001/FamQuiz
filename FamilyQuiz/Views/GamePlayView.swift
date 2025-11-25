//
//  GamePlayView.swift
//  Multi-User Family Quiz Arena
//
//  Main gameplay screen showing questions, answers, timer, and scores
//  Handles countdown, question display, and answer selection
//

import SwiftUI

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedAnswer: Int? = nil
    @State private var countdownValue: Int = 3

    var body: some View {
        ZStack {
            // Dynamic background based on category
            if let question = viewModel.currentQuestion {
                CategoryBackground(category: question.category)
            } else {
                Color.black.ignoresSafeArea()
            }

            // Main content
            if viewModel.gameState == .countdown {
                CountdownView(countdownValue: $countdownValue)
                    .onAppear {
                        startCountdownAnimation()
                    }
            } else {
                VStack(spacing: 0) {
                    // Top bar with progress and timer
                    TopBarView(viewModel: viewModel)
                        .padding(.top, 40)
                        .padding(.horizontal, 80)

                    Spacer()

                    // Question and answers
                    if let question = viewModel.currentQuestion {
                        QuestionView(
                            question: question,
                            selectedAnswer: $selectedAnswer,
                            showCorrectAnswer: viewModel.showCorrectAnswer,
                            onAnswerSelected: { index in
                                handleAnswerSelection(index)
                            }
                        )
                        .padding(.horizontal, 100)
                    }

                    Spacer()

                    // Player scores at bottom
                    PlayerScoresBar(players: viewModel.players)
                        .padding(.bottom, 50)
                        .padding(.horizontal, 80)
                }
            }
        }
        .onChange(of: viewModel.currentQuestionIndex) { _ in
            selectedAnswer = nil
        }
    }

    // MARK: - Helper Methods

    private func startCountdownAnimation() {
        countdownValue = 3

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
                SoundManager.shared.playTick()
            } else {
                timer.invalidate()
            }
        }
    }

    private func handleAnswerSelection(_ index: Int) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = index
        SoundManager.shared.playButtonTap()

        // Submit answer via Siri Remote (for demo/testing)
        viewModel.selectAnswerWithRemote(index)
    }
}

// MARK: - Countdown View

struct CountdownView: View {
    @Binding var countdownValue: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Get Ready!")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)

                Text("\(countdownValue)")
                    .font(.system(size: 200, weight: .bold))
                    .foregroundColor(.yellow)
                    .scaleEffect(countdownValue == 3 ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: countdownValue)
            }
        }
    }
}

// MARK: - Top Bar View

struct TopBarView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 40) {
            // Question progress
            VStack(alignment: .leading, spacing: 10) {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(.white)

                ProgressView(value: viewModel.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .frame(width: 400)
                    .scaleEffect(x: 1, y: 3, anchor: .center)
            }

            Spacer()

            // Category badge
            if let question = viewModel.currentQuestion {
                HStack(spacing: 15) {
                    Text(question.category.emoji)
                        .font(.system(size: 42))

                    Text(question.category.rawValue)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 35)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.35), lineWidth: 2)
                        )
                )
            }

            Spacer()

            // Timer
            TimerView(timeRemaining: viewModel.timeRemaining, totalTime: viewModel.config.timePerQuestion)
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Timer View

struct TimerView: View {
    let timeRemaining: TimeInterval
    let totalTime: TimeInterval

    private var progress: Double {
        timeRemaining / totalTime
    }

    private var timerColor: Color {
        if progress > 0.5 {
            return .green
        } else if progress > 0.25 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 8)
                .frame(width: 120, height: 120)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: timeRemaining)

            // Time text
            VStack(spacing: 5) {
                Text("\(Int(timeRemaining))")
                    .font(.system(size: 45, weight: .bold))
                    .foregroundColor(timerColor)

                Text("sec")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .scaleEffect(progress < 0.2 ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: progress < 0.2)
    }
}

// MARK: - Question View

struct QuestionView: View {
    let question: Question
    @Binding var selectedAnswer: Int?
    let showCorrectAnswer: Bool
    let onAnswerSelected: (Int) -> Void

    var body: some View {
        VStack(spacing: 50) {
            // Question text
            Text(question.text)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.5))
                )
                .shadow(color: .black.opacity(0.3), radius: 20)

            // Answer options
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 25) {
                ForEach(0..<question.answers.count, id: \.self) { index in
                    AnswerButton(
                        text: question.answers[index],
                        index: index,
                        isSelected: selectedAnswer == index,
                        isCorrect: showCorrectAnswer && index == question.correctAnswerIndex,
                        isWrong: showCorrectAnswer && selectedAnswer == index && index != question.correctAnswerIndex,
                        showResult: showCorrectAnswer,
                        action: {
                            if !showCorrectAnswer {
                                onAnswerSelected(index)
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Answer Button

struct AnswerButton: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showResult: Bool
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private var buttonColor: Color {
        if showResult {
            if isCorrect {
                return .green
            } else if isWrong {
                return .red
            }
        }
        return isSelected ? Color.blue : Color.white.opacity(0.18)
    }

    private var borderColor: Color {
        if showResult {
            if isCorrect {
                return .green
            } else if isWrong {
                return .red
            }
        }
        return isFocused ? Color.yellow : Color.white.opacity(0.35)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Answer letter
                Text(answerLetter)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.15)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )

                // Answer text
                Text(text)
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                // Result indicator
                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.green)
                    } else if isWrong {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 35)
            .frame(height: 140)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    buttonColor.opacity(0.95),
                                    Color.white.opacity(showResult ? 0.25 : 0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(borderColor, lineWidth: isFocused ? 6 : 3)
                }
            )
            .scaleEffect(isFocused ? 1.06 : 1.0)
            .shadow(color: borderColor.opacity(0.55), radius: isFocused ? 24 : 12, x: 0, y: 14)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .disabled(showResult)
    }

    private var answerLetter: String {
        ["A", "B", "C", "D"][index]
    }
}

// MARK: - Player Scores Bar

struct PlayerScoresBar: View {
    let players: [Player]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(players) { player in
                PlayerScoreCard(player: player)
            }
        }
    }
}

struct PlayerScoreCard: View {
    let player: Player

    var body: some View {
        HStack(spacing: 15) {
            Text(player.avatar)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 5) {
                Text(player.name)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.white)

                Text("\(player.score) pts")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.yellow)
            }

            if player.hasAnswered {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(player.hasAnswered ? Color.green : Color.white.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Category Background

struct CategoryBackground: View {
    let category: QuizCategory

    private var gradientColors: [Color] {
        switch category {
        case .science:
            return [Color.blue, Color.purple]
        case .history:
            return [Color.brown, Color.orange]
        case .geography:
            return [Color.green, Color.teal]
        case .entertainment:
            return [Color.pink, Color.purple]
        case .sports:
            return [Color.orange, Color.red]
        case .generalKnowledge:
            return [Color.indigo, Color.blue]
        }
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GameViewModel()
        viewModel.addTestPlayer(name: "Alex", avatar: "🦊")
        viewModel.addTestPlayer(name: "Sam", avatar: "🐻")
        viewModel.startGame()

        return GamePlayView(viewModel: viewModel)
    }
}
