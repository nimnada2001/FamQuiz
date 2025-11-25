//
//  AccessibilityHelpers.swift
//  Multi-User Family Quiz Arena
//
//  Accessibility and Focus Engine optimization utilities
//  Ensures the app is usable with Siri Remote and accessible to all users
//

import SwiftUI

// MARK: - Focus Environment Extensions

extension View {
    /// Make view focusable with enhanced visual feedback for tvOS
    func tvOSFocusable(isFocused: Binding<Bool>) -> some View {
        self.modifier(TVOSFocusModifier(isFocused: isFocused))
    }

    /// Add accessibility labels for VoiceOver support
    func quizAccessibility(label: String, hint: String? = nil, value: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
    }

    /// Enhanced button for tvOS with proper focus handling
    func tvOSButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(TVOSButtonStyle())
    }
}

// MARK: - tvOS Focus Modifier

struct TVOSFocusModifier: ViewModifier {
    @Binding var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isFocused ? 1.08 : 1.0)
            .brightness(isFocused ? 0.15 : 0)
            .shadow(color: isFocused ? .white.opacity(0.5) : .clear, radius: 20)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - tvOS Button Style

struct TVOSButtonStyle: ButtonStyle {
    @FocusState private var isFocused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : (isFocused ? 1.08 : 1.0))
            .brightness(isFocused ? 0.15 : 0)
            .shadow(color: isFocused ? .white.opacity(0.5) : .clear, radius: 20)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFocused)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
            .focused($isFocused)
    }
}

// MARK: - Focus Guide Helpers

/// Helper to create custom focus guides for complex navigation
struct FocusGuideHelper {
    /// Create a focus guide that redirects focus from one view to another
    static func createRedirectGuide(
        from source: some View,
        to destination: some View
    ) -> some View {
        // tvOS automatically handles focus guides, but this provides a structure
        // for custom focus behavior if needed
        return source
    }

    /// Priority levels for focus
    enum FocusPriority {
        case high
        case medium
        case low

        var value: Int {
            switch self {
            case .high: return 100
            case .medium: return 50
            case .low: return 10
            }
        }
    }
}

// MARK: - Accessibility Labels

enum AccessibilityLabels {
    // Main Menu
    static let startGameButton = "Start New Game"
    static let quickPlayButton = "Quick Play with test players"
    static let historyButton = "View game history"
    static let settingsButton = "Open settings"

    // Lobby
    static let addPlayerButton = "Add test player to game"
    static let startButton = "Start the quiz game"
    static let cancelButton = "Cancel and return to menu"

    // Gameplay
    static func answerButton(_ letter: String, _ text: String) -> String {
        "Answer \(letter): \(text)"
    }

    static func questionProgress(_ current: Int, _ total: Int) -> String {
        "Question \(current) of \(total)"
    }

    static func timeRemaining(_ seconds: Int) -> String {
        "\(seconds) seconds remaining"
    }

    static func playerScore(_ name: String, _ score: Int) -> String {
        "\(name) has \(score) points"
    }

    // Game Over
    static func leaderboardRank(_ rank: Int, _ name: String, _ score: Int) -> String {
        "Rank \(rank): \(name) with \(score) points"
    }

    static let playAgainButton = "Play another game"
    static let mainMenuButton = "Return to main menu"
}

// MARK: - Color Accessibility

extension Color {
    /// High contrast colors for better visibility
    static let highContrastText = Color.white
    static let highContrastBackground = Color.black

    /// Color blind friendly palette
    enum ColorBlindSafe {
        static let blue = Color(red: 0.0, green: 0.45, blue: 0.70)
        static let orange = Color(red: 0.90, green: 0.60, blue: 0.0)
        static let green = Color(red: 0.0, green: 0.60, blue: 0.50)
        static let yellow = Color(red: 0.95, green: 0.90, blue: 0.25)
        static let red = Color(red: 0.80, green: 0.40, blue: 0.0)
        static let purple = Color(red: 0.80, green: 0.60, blue: 0.70)
    }

    /// Get contrasting color for text
    var contrastColor: Color {
        // Simplified contrast calculation
        return .white
    }
}

// MARK: - Reduced Motion Support

struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let normalAnimation: Animation
    let reducedAnimation: Animation

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? reducedAnimation : normalAnimation, value: UUID())
    }
}

extension View {
    /// Apply animation with reduced motion support
    func reducedMotionAnimation(
        normal: Animation = .spring(),
        reduced: Animation = .linear(duration: 0.1)
    ) -> some View {
        modifier(ReducedMotionModifier(normalAnimation: normal, reducedAnimation: reduced))
    }
}

// MARK: - Text Size Scaling

extension View {
    /// Make text dynamically scalable for accessibility
    func dynamicTypeSize(minimum: DynamicTypeSize = .small, maximum: DynamicTypeSize = .xxxLarge) -> some View {
        self.dynamicTypeSize(minimum...maximum)
    }
}

// MARK: - VoiceOver Helpers

struct VoiceOverHelper {
    /// Check if VoiceOver is running
    static var isVoiceOverRunning: Bool {
        #if os(iOS)
        return UIAccessibility.isVoiceOverRunning
        #else
        // tvOS VoiceOver check would go here
        return false
        #endif
    }

    /// Post accessibility announcement
    static func announce(_ message: String) {
        #if os(iOS)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }
}

// MARK: - Game-Specific Accessibility

extension View {
    /// Add accessibility for answer buttons
    func answerButtonAccessibility(
        letter: String,
        text: String,
        isCorrect: Bool,
        isSelected: Bool,
        showResult: Bool
    ) -> some View {
        var label = "Answer \(letter): \(text)"

        if showResult {
            if isCorrect {
                label += ", Correct answer"
            } else if isSelected {
                label += ", Incorrect"
            }
        } else if isSelected {
            label += ", Selected"
        }

        return self
            .accessibilityLabel(label)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// Add accessibility for player score
    func playerScoreAccessibility(name: String, score: Int, hasAnswered: Bool) -> some View {
        let label = "\(name), \(score) points"
        let value = hasAnswered ? "Has answered" : "Waiting for answer"

        return self
            .accessibilityLabel(label)
            .accessibilityValue(value)
    }

    /// Add accessibility for timer
    func timerAccessibility(seconds: Int) -> some View {
        self
            .accessibilityLabel("Time remaining")
            .accessibilityValue("\(seconds) seconds")
    }
}

// MARK: - Focus Section Definitions

/// Defines focus sections for better navigation
enum FocusSection: Hashable {
    case menu
    case lobby
    case answers
    case actions
    case history

    var accessibilityLabel: String {
        switch self {
        case .menu: return "Main menu options"
        case .lobby: return "Lobby controls"
        case .answers: return "Answer options"
        case .actions: return "Action buttons"
        case .history: return "Game history"
        }
    }
}

// MARK: - Siri Remote Gesture Support

struct RemoteGestureHelper {
    /// Detect swipe gestures on Siri Remote
    static func addSwipeGestures(
        onUp: (() -> Void)? = nil,
        onDown: (() -> Void)? = nil,
        onLeft: (() -> Void)? = nil,
        onRight: (() -> Void)? = nil
    ) -> some Gesture {
        // In practice, tvOS handles these automatically via Focus Engine
        // This is a placeholder for custom gesture handling
        return TapGesture()
    }

    /// Handle play/pause button on Siri Remote
    static func handlePlayPause(_ action: @escaping () -> Void) {
        // Custom handling if needed
    }

    /// Handle menu button on Siri Remote
    static func handleMenu(_ action: @escaping () -> Void) {
        // Custom handling if needed
    }
}

// MARK: - Game Controller Support Notes

/*
 GAME CONTROLLER INTEGRATION:

 To support Game Controllers (including Siri Remote as a game controller):

 1. Import GameController framework
 2. Register for controller connection notifications
 3. Map button inputs to game actions

 Example implementation:

 import GameController

 class GameControllerManager: ObservableObject {
     @Published var connectedController: GCController?

     init() {
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(controllerDidConnect),
             name: .GCControllerDidConnect,
             object: nil
         )

         NotificationCenter.default.addObserver(
             self,
             selector: #selector(controllerDidDisconnect),
             name: .GCControllerDidDisconnect,
             object: nil
         )
     }

     @objc func controllerDidConnect(_ notification: Notification) {
         guard let controller = notification.object as? GCController else { return }
         connectedController = controller

         // Map buttons
         controller.extendedGamepad?.buttonA.valueChangedHandler = { button, value, pressed in
             if pressed {
                 // Handle A button (select/confirm)
             }
         }

         controller.extendedGamepad?.buttonB.valueChangedHandler = { button, value, pressed in
             if pressed {
                 // Handle B button (back/cancel)
             }
         }
     }

     @objc func controllerDidDisconnect(_ notification: Notification) {
         connectedController = nil
     }
 }

 Button Mapping Recommendations:
 - A Button: Select answer / Confirm
 - B Button: Cancel / Go back
 - X Button: Quick action / Hint
 - Y Button: Alternative action
 - D-Pad: Navigate between answers (handled by Focus Engine)
 - Menu Button: Pause / Settings
 - Play/Pause: Start game / Pause timer
 */
