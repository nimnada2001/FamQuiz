//
//  GameViewModel.swift
//  Multi-User Family Quiz Arena
//
//  Main ViewModel implementing MVVM architecture
//  Manages game state, player interactions, and quiz flow
//

import SwiftUI
import Combine

/// Game state enumeration
enum GameState {
    case menu
    case lobby
    case countdown
    case playing
    case questionResult
    case gameOver
}

/// Main ViewModel for game logic and state management
class GameViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var gameState: GameState = .menu
    @Published var players: [Player] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var timeRemaining: TimeInterval = 15.0
    @Published var questions: [Question] = []
    @Published var showCorrectAnswer: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var config: QuizConfig = QuizConfig()

    // MARK: - Dependencies

    private let multipeerManager: MultipeerManager
    private let soundManager: SoundManager
    private let persistenceController: PersistenceController

    // MARK: - Private Properties

    private var timer: Timer?
    private var countdownTimer: Timer?
    private var questionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var isLastQuestion: Bool {
        return currentQuestionIndex == questions.count - 1
    }

    var progressPercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    // MARK: - Initialization

    init(
        multipeerManager: MultipeerManager = MultipeerManager(),
        soundManager: SoundManager = SoundManager.shared,
        persistenceController: PersistenceController = .shared
    ) {
        self.multipeerManager = multipeerManager
        self.soundManager = soundManager
        self.persistenceController = persistenceController

        setupMultipeerCallbacks()
    }

    // MARK: - Game Flow Methods

    /// Start hosting a new game
    func startHosting() {
        multipeerManager.startHosting()
        gameState = .lobby
        players.removeAll()
        print("🎮 Hosting new game")
    }

    /// Begin the quiz game with current players
    func startGame() {
        guard !players.isEmpty else {
            print("⚠️ Cannot start game without players")
            return
        }

        // Load questions
        questions = selectQuestions(count: config.numberOfQuestions)

        // Reset player scores
        for i in 0..<players.count {
            players[i].score = 0
            players[i].hasAnswered = false
        }

        currentQuestionIndex = 0
        gameState = .countdown

        // Send game starting message to all players
        multipeerManager.sendToAllPlayers(.gameStarting)

        // Start countdown
        startCountdown()
    }

    /// Start countdown before first question
    private func startCountdown() {
        var countdown = 3
        soundManager.playCountdown()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            countdown -= 1

            if countdown == 0 {
                timer.invalidate()
                self?.presentNextQuestion()
            }
        }
    }

    /// Present the next question to players
    func presentNextQuestion() {
        guard let question = currentQuestion else {
            endGame()
            return
        }

        // Reset answer state for all players
        for i in 0..<players.count {
            players[i].resetForNewQuestion()
        }

        gameState = .playing
        timeRemaining = config.timePerQuestion
        questionStartTime = Date()
        showCorrectAnswer = false

        // Send question to all players
        let message = GameMessage.newQuestion(
            questionText: question.text,
            answers: question.answers,
            questionNumber: currentQuestionIndex + 1
        )
        multipeerManager.sendToAllPlayers(message)

        // Start question timer
        startQuestionTimer()

        // Play question sound
        soundManager.playQuestionStart()
    }

    /// Start timer for current question
    private func startQuestionTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeRemaining -= 0.1

            if self.timeRemaining <= 0 {
                self.onQuestionTimeout()
            }
        }
    }

    /// Handle question timeout
    private func onQuestionTimeout() {
        timer?.invalidate()
        showQuestionResult()
    }

    /// Process player answer
    func submitAnswer(playerId: UUID, answerIndex: Int, timeElapsed: TimeInterval) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }),
              let question = currentQuestion,
              !players[playerIndex].hasAnswered else {
            return
        }

        // Mark player as answered
        players[playerIndex].hasAnswered = true
        players[playerIndex].answerTime = timeElapsed

        // Check if answer is correct
        let isCorrect = answerIndex == question.correctAnswerIndex

        if isCorrect {
            // Calculate score with speed bonus
            var points = config.pointsForCorrect

            if config.bonusForSpeed {
                // Bonus points for fast answers (up to 50 extra points)
                let speedBonus = Int((1.0 - (timeElapsed / config.timePerQuestion)) * 50)
                points += max(0, speedBonus)
            }

            players[playerIndex].score += points

            // Send result to player
            let message = GameMessage.answerResult(
                playerId: playerId,
                correct: true,
                newScore: players[playerIndex].score
            )
            multipeerManager.sendToAllPlayers(message)
        } else {
            // Send incorrect result
            let message = GameMessage.answerResult(
                playerId: playerId,
                correct: false,
                newScore: players[playerIndex].score
            )
            multipeerManager.sendToAllPlayers(message)
        }

        // Check if all players have answered
        if players.allSatisfy({ $0.hasAnswered }) {
            timer?.invalidate()
            showQuestionResult()
        }
    }

    /// Show the correct answer and results
    private func showQuestionResult() {
        showCorrectAnswer = true
        gameState = .questionResult

        // Play result sound
        soundManager.playQuestionEnd()

        // Wait 3 seconds before moving to next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.moveToNextQuestion()
        }
    }

    /// Move to next question or end game
    private func moveToNextQuestion() {
        if isLastQuestion {
            endGame()
        } else {
            currentQuestionIndex += 1
            presentNextQuestion()
        }
    }

    /// End the game and show results
    func endGame() {
        timer?.invalidate()
        gameState = .gameOver

        // Sort players by score
        players.sort { $0.score > $1.score }

        // Send final scores to all players
        let scores = players.map { PlayerScore(id: $0.id, name: $0.name, score: $0.score, avatar: $0.avatar) }
        multipeerManager.sendToAllPlayers(.gameEnded(finalScores: scores))

        // Play game over sound
        soundManager.playGameEnd()

        // Save game session to Core Data
        persistenceController.saveGameSession(players: players, numberOfQuestions: questions.count)

        print("🏁 Game ended")
    }

    /// Return to main menu
    func returnToMenu() {
        timer?.invalidate()
        countdownTimer?.invalidate()
        multipeerManager.stopHosting()
        gameState = .menu
        players.removeAll()
        questions.removeAll()
        currentQuestionIndex = 0
    }

    /// Restart game with same players
    func restartGame() {
        startGame()
    }

    // MARK: - Player Management

    /// Add a test player (for prototype/testing without real devices)
    func addTestPlayer(name: String, avatar: String = "👤") {
        let player = Player(name: name, avatar: avatar)
        players.append(player)
        print("🤖 Added test player: \(name)")
    }

    /// Remove player from game
    func removePlayer(playerId: UUID) {
        players.removeAll { $0.id == playerId }
    }

    // MARK: - Question Selection

    /// Select questions based on configuration
    private func selectQuestions(count: Int) -> [Question] {
        var availableQuestions = Question.sampleQuestions

        // Filter by categories if specified
        if !config.categories.isEmpty {
            availableQuestions = availableQuestions.filter { config.categories.contains($0.category) }
        }

        // Shuffle and take requested count
        return Array(availableQuestions.shuffled().prefix(count))
    }

    // MARK: - Multipeer Setup

    /// Setup multipeer connectivity callbacks
    private func setupMultipeerCallbacks() {
        // Player joined
        multipeerManager.onPlayerJoined = { [weak self] player in
            guard let self = self else { return }
            self.players.append(player)
            print("👤 Player joined: \(player.name)")
        }

        // Player left
        multipeerManager.onPlayerLeft = { [weak self] playerId in
            self?.removePlayer(playerId: playerId)
            print("👋 Player left")
        }

        // Player answered
        multipeerManager.onPlayerAnswer = { [weak self] playerId, answerIndex, timeElapsed in
            self?.submitAnswer(playerId: playerId, answerIndex: answerIndex, timeElapsed: timeElapsed)
        }
    }

    // MARK: - Siri Remote / Game Controller Support

    /// Handle answer selection via Siri Remote (for single player or testing)
    func selectAnswerWithRemote(_ answerIndex: Int) {
        guard let question = currentQuestion,
              gameState == .playing else {
            return
        }

        // For testing, use first player or create one
        if players.isEmpty {
            addTestPlayer(name: "Remote Player", avatar: "🎮")
        }

        let playerId = players[0].id
        let timeElapsed = Date().timeIntervalSince(questionStartTime ?? Date())

        submitAnswer(playerId: playerId, answerIndex: answerIndex, timeElapsed: timeElapsed)
    }
}
