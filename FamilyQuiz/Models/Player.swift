//
//  Player.swift
//  Multi-User Family Quiz Arena
//
//  Model representing a player in the quiz game
//  Tracks player identity, score, and connection status
//

import Foundation

/// Represents a player in the quiz game
struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var score: Int
    var avatar: String // Emoji or avatar identifier
    var isConnected: Bool
    var hasAnswered: Bool // Track if player answered current question
    var answerTime: TimeInterval? // Time taken to answer

    init(id: UUID = UUID(), name: String, avatar: String = "👤", score: Int = 0) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.score = score
        self.isConnected = true
        self.hasAnswered = false
        self.answerTime = nil
    }

    /// Reset answer state for new question
    mutating func resetForNewQuestion() {
        self.hasAnswered = false
        self.answerTime = nil
    }
}

/// Message types for player-TV communication
enum PlayerMessage: Codable {
    case join(playerName: String, avatar: String)
    case answer(playerId: UUID, answerIndex: Int, timeElapsed: TimeInterval)
    case ready
    case leave(playerId: UUID)
}

/// Message types for TV-player communication
enum GameMessage: Codable {
    case playerJoined(playerId: UUID)
    case gameStarting
    case newQuestion(questionText: String, answers: [String], questionNumber: Int)
    case answerResult(playerId: UUID, correct: Bool, newScore: Int)
    case gameEnded(finalScores: [PlayerScore])
    case error(message: String)
}

/// Simplified score structure for transmission
struct PlayerScore: Codable, Identifiable {
    let id: UUID
    let name: String
    let score: Int
    let avatar: String
}
