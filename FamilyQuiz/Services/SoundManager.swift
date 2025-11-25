//
//  SoundManager.swift
//  Multi-User Family Quiz Arena
//
//  Manages sound effects and audio feedback
//  Plays sounds for game events (correct/wrong answers, timer, etc.)
//

import AVFoundation
import SwiftUI
import Combine

/// Manages all sound effects for the quiz game
class SoundManager: ObservableObject {
    // Singleton instance
    static let shared = SoundManager()

    // MARK: - Properties

    @Published var isSoundEnabled: Bool = true

    private var players: [String: AVAudioPlayer] = [:]

    // MARK: - Sound Types

    enum SoundEffect: String {
        case correctAnswer = "correct"
        case wrongAnswer = "wrong"
        case questionStart = "question_start"
        case questionEnd = "question_end"
        case countdown = "countdown"
        case gameStart = "game_start"
        case gameEnd = "game_end"
        case buttonTap = "button_tap"
        case playerJoin = "player_join"
        case tick = "tick"
    }

    // MARK: - Initialization

    private init() {
        // Note: In a production app, you would load actual sound files here
        // For this prototype, we're setting up the structure
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    /// Configure audio session for game sounds
    private func setupAudioSession() {
        do {
            // Set up audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }

    // MARK: - Sound Playback Methods

    /// Play a sound effect
    func playSound(_ sound: SoundEffect, volume: Float = 1.0) {
        guard isSoundEnabled else { return }

        // In a real implementation, you would load and play actual audio files
        // For this prototype, we'll use system sounds as placeholders

        switch sound {
        case .correctAnswer:
            playSystemSound(1054) // SMS received sound as placeholder
        case .wrongAnswer:
            playSystemSound(1053) // SMS sent sound as placeholder
        case .questionStart:
            playSystemSound(1105) // Camera shutter
        case .questionEnd:
            playSystemSound(1104) // Camera shutter
        case .countdown:
            playSystemSound(1103) // Begin recording
        case .gameStart:
            playSystemSound(1000) // Mail sent
        case .gameEnd:
            playSystemSound(1001) // Mail received
        case .buttonTap:
            playSystemSound(1104) // Camera shutter
        case .playerJoin:
            playSystemSound(1000) // Mail sent
        case .tick:
            playSystemSound(1103) // Tick
        }
    }

    /// Play system sound by ID
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Convenience Methods

    func playCorrectAnswer() {
        playSound(.correctAnswer)
        // Add haptic feedback if available
        provideHapticFeedback(.success)
    }

    func playWrongAnswer() {
        playSound(.wrongAnswer)
        provideHapticFeedback(.error)
    }

    func playQuestionStart() {
        playSound(.questionStart)
    }

    func playQuestionEnd() {
        playSound(.questionEnd)
    }

    func playCountdown() {
        playSound(.countdown)
    }

    func playGameStart() {
        playSound(.gameStart)
    }

    func playGameEnd() {
        playSound(.gameEnd)
    }

    func playButtonTap() {
        playSound(.buttonTap)
    }

    func playPlayerJoin() {
        playSound(.playerJoin)
    }

    func playTick() {
        playSound(.tick)
    }

    // MARK: - Haptic Feedback

    /// Provide haptic feedback (for devices that support it)
    private func provideHapticFeedback(_ type: HapticFeedbackType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        switch type {
        case .success:
            generator.notificationOccurred(.success)
        case .error:
            generator.notificationOccurred(.error)
        case .warning:
            generator.notificationOccurred(.warning)
        }
        #endif
    }

    // Custom enum for haptic feedback types (tvOS compatible)
    private enum HapticFeedbackType {
        case success
        case error
        case warning
    }

    // MARK: - Settings

    /// Toggle sound on/off
    func toggleSound() {
        isSoundEnabled.toggle()
        UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
    }

    /// Load sound settings
    func loadSettings() {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
    }
}

// MARK: - Sound File Notes

/*
 PRODUCTION IMPLEMENTATION:

 To use actual sound files in production:

 1. Add sound files to the project (MP3, WAV, or M4A format)
    - correct.mp3 (celebratory chime for correct answers)
    - wrong.mp3 (buzzer sound for incorrect answers)
    - question_start.mp3 (attention-grabbing sound)
    - countdown.mp3 (tick-tock sound)
    - game_start.mp3 (upbeat game start music)
    - game_end.mp3 (victory fanfare)

 2. Load sounds in init():

    private func loadSound(named name: String, withExtension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ Could not find sound file: \(name).\(ext)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
        } catch {
            print("❌ Could not load sound file: \(error)")
        }
    }

 3. Update playSound method:

    func playSound(_ sound: SoundEffect, volume: Float = 1.0) {
        guard isSoundEnabled else { return }

        let soundName = sound.rawValue

        if let player = players[soundName] {
            player.volume = volume
            player.currentTime = 0
            player.play()
        }
    }

 Sound design recommendations:
 - Keep sounds short (< 2 seconds) for responsiveness
 - Use pleasant, non-jarring sounds suitable for family audience
 - Ensure sounds are clearly distinguishable from each other
 - Test volume levels across different devices
 - Consider accessibility (don't rely solely on sound for feedback)
 */
