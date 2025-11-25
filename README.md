# Multi-User Family Quiz Arena

A tvOS SwiftUI application that brings multiplayer quiz gaming to your living room. Players join using their iPhones as controllers (via Multipeer Connectivity) or the Siri Remote, competing in real-time on shared questions displayed on Apple TV.

## Features

### Core Gameplay
- **Multiplayer Support**: Up to multiple players can join simultaneously
- **Real-Time Competition**: Live score updates as players answer
- **Countdown Timer**: 15-second timer per question with visual feedback
- **Multiple Choice Questions**: Four answer options per question
- **Instant Feedback**: Immediate visual and audio feedback for correct/wrong answers

### UI/UX
- **tvOS Focus Engine Optimized**: Seamless navigation with Siri Remote
- **Large Screen Readable**: Designed for living room viewing distances
- **Colorful Categories**: Visual distinction between question categories
  - 🔬 Science (Blue)
  - 📜 History (Purple)
  - 🌍 Geography (Green)
  - 🎬 Entertainment (Pink)
  - ⚽️ Sports (Orange)
  - 🧠 General Knowledge (Yellow)

### Animations & Effects
- **Question Transitions**: Smooth slide and fade animations
- **Countdown Animation**: Engaging 3-2-1 countdown before questions
- **Confetti Celebration**: Victory animation on game over screen
- **Focus Animations**: Scale and glow effects on focused elements
- **Progress Indicators**: Animated progress bars and circular timers

### Networking
- **Multipeer Connectivity**: Local network player discovery and connection
- **Auto-Discovery**: iPhones automatically find the Quiz TV
- **Reliable Messaging**: Error-resistant message passing
- **Connection Status**: Visual indicators for player connectivity

### Data Persistence
- **Core Data Integration**: Save game history locally
- **Game Statistics**: Track players, scores, and dates
- **History View**: Review past games and performance

### Accessibility
- **VoiceOver Support**: Full accessibility labels and hints
- **Reduced Motion**: Respects accessibility preferences
- **High Contrast**: Optimized color schemes for visibility
- **Dynamic Type**: Text scaling support

## Architecture

### MVVM Pattern
```
Models/
├── Player.swift          # Player data model and message types
└── Question.swift        # Question model with sample data

ViewModels/
└── GameViewModel.swift   # Central game state management

Views/
├── MainMenuView.swift    # Entry point and navigation
├── LobbyView.swift       # Player joining screen
├── GamePlayView.swift    # Main quiz gameplay
├── GameOverView.swift    # Results and leaderboard
└── GameHistoryView.swift # Past games review

Networking/
└── MultipeerManager.swift # Multipeer connectivity handling

Services/
└── SoundManager.swift    # Audio feedback system

Persistence/
└── PersistenceController.swift # Core Data stack

Utilities/
├── AnimationHelpers.swift      # Reusable animations
└── AccessibilityHelpers.swift  # Accessibility utilities
```

## Code Structure

### Separation of Concerns
- **Models**: Pure data structures, no business logic
- **ViewModels**: Game logic, state management, network coordination
- **Views**: UI presentation only, no business logic
- **Services**: Shared functionality (sound, persistence)

### Key Design Patterns
- **Singleton**: `SoundManager`, `PersistenceController`
- **Observer**: SwiftUI's `@Published` and `@ObservedObject`
- **Delegate**: Multipeer connectivity callbacks
- **Repository**: Core Data access layer

## Setup Instructions

### Requirements
- Xcode 14.0 or later
- tvOS 15.0 or later
- Swift 5.7 or later

### Building the Project

1. **Open in Xcode**:
   ```bash
   open FamilyQuiz.xcodeproj
   ```

2. **Select tvOS Target**:
   - Choose "Apple TV" simulator or device
   - Ensure bundle identifier is unique

3. **Configure Signing**:
   - Select your development team
   - Automatic signing recommended for development

4. **Build and Run**:
   - ⌘R to build and run
   - Use simulated Siri Remote in simulator

### Testing Without Multiple Devices

The app includes a "Quick Play (Demo)" mode that:
- Creates 3 test players automatically
- Allows Siri Remote to answer questions
- Demonstrates full gameplay flow
- Perfect for development and testing

## Usage

### Starting a Game

1. **Launch App**: Main menu appears with quiz arena logo
2. **Choose Mode**:
   - "Start New Game": Wait for iPhone players to join
   - "Quick Play (Demo)": Instant play with test players
3. **Lobby**: View connected players and add test players if needed
4. **Start**: Begin the quiz when ready

### During Gameplay

- **Question Display**: Large text optimized for TV viewing
- **Timer**: Circular countdown shows remaining time
- **Answers**: Four buttons (A, B, C, D) navigable with Siri Remote
- **Player Scores**: Bottom bar shows all player progress
- **Visual Feedback**:
  - Green highlight for correct answers
  - Red highlight for wrong answers
  - Checkmarks show who has answered

### Game Over

- **Leaderboard**: Ranked by final score
- **Medals**: 🥇 🥈 🥉 for top 3 players
- **Confetti**: Celebratory animation
- **Options**: Play again or return to menu

### Game History

- View all past games
- See winner and scores for each session
- Expand to view all player results
- Stored locally via Core Data

## Customization

### Adding Questions

Edit `Models/Question.swift`:

```swift
Question(
    text: "Your question here?",
    answers: ["Option A", "Option B", "Option C", "Option D"],
    correctAnswerIndex: 0, // 0-3 for A-D
    category: .science,
    difficulty: .medium,
    explanation: "Optional explanation"
)
```

### Adjusting Game Settings

Modify `QuizConfig` in `Question.swift`:

```swift
var config = QuizConfig()
config.numberOfQuestions = 15 // Change question count
config.timePerQuestion = 20.0 // Change time limit
config.pointsForCorrect = 100  // Base points per question
config.bonusForSpeed = true    // Enable/disable speed bonus
```

### Sound Effects

Replace placeholder sounds in `SoundManager.swift`:

1. Add sound files to project (`.mp3`, `.wav`, `.m4a`)
2. Update `loadSound()` method to load files
3. Sounds will auto-play at appropriate game events

### Color Schemes

Customize category colors in `Question.swift`:

```swift
var color: String {
    switch self {
    case .science: return "blue"  // Change to any Color name
    // ...
    }
}
```

## Multiplayer Setup (iPhone Controller)

### Creating iPhone Companion App

1. **New iOS Target**: Add iOS app target to project
2. **Share Code**: Link `Models/` and `Networking/` to both targets
3. **Create Controller UI**:
   - Browse for games
   - Display questions
   - Send answers to TV
4. **Mirror Networking**: Use same `MultipeerManager`

### Communication Flow

```
iPhone                          Apple TV
  |                                |
  |--[1. Browse for games]-------->|
  |<--[2. Found TV host]-----------|
  |--[3. Join request]------------>|
  |<--[4. Accepted + Player ID]----|
  |<--[5. New question]------------|
  |--[6. Submit answer]----------->|
  |<--[7. Answer result]-----------|
  |<--[8. Game over + scores]------|
```

## Technical Details

### Multipeer Connectivity

- **Service Type**: `"familyquiz"` (max 15 chars)
- **Discovery Info**: Role identification (host/player)
- **Security**: Encryption required for all connections
- **Reliability**: All messages sent with `.reliable` mode

### Core Data Schema

**GameSession**:
- `id`: UUID
- `date`: Date
- `numberOfPlayers`: Int16
- `numberOfQuestions`: Int16
- `duration`: Double
- Relationship: `playerResults` (one-to-many)

**PlayerResult**:
- `id`: UUID
- `playerName`: String
- `avatar`: String
- `score`: Int32
- `correctAnswers`: Int16
- Relationship: `gameSession` (many-to-one)

### Focus Engine

The app leverages tvOS Focus Engine for navigation:
- Automatic focus management
- Custom focus animations via `@FocusState`
- Enhanced visual feedback (scale, glow, brightness)
- Optimized button spacing for easy navigation

## Performance Considerations

- **Animation Performance**: Uses native SwiftUI animations
- **Network Efficiency**: Minimal data transfer via Codable messages
- **Memory Management**: Proper cleanup of timers and observers
- **Core Data**: Batch operations for game history

## Known Limitations (Prototype)

1. **Sound Effects**: Uses system sounds as placeholders
2. **Single TV Instance**: No multiple game rooms
3. **Fixed Question Pool**: 20 sample questions included
4. **No Online Mode**: Local network only
5. **No Player Authentication**: No persistent player profiles

## Future Enhancements

- [ ] Add difficulty selection (easy, medium, hard)
- [ ] Category-specific games
- [ ] Timed rounds (all questions in X minutes)
- [ ] Team mode (2v2, 3v3)
- [ ] Question editor for custom quizzes
- [ ] iCloud sync for cross-device history
- [ ] Achievements and badges
- [ ] Sound effect library
- [ ] Background music
- [ ] Question image support
- [ ] Hints system
- [ ] Lifelines (50/50, skip, etc.)

## Troubleshooting

### Players Can't Connect

1. **Same Network**: Ensure all devices on same WiFi
2. **Firewall**: Check network doesn't block Bonjour
3. **Permissions**: Verify local network permission granted
4. **Restart**: Kill and relaunch app on both devices

### Focus Navigation Issues

1. **Update tvOS**: Ensure tvOS 15+ installed
2. **Remote Paired**: Check Siri Remote is paired
3. **Reset Focus**: Return to menu and re-enter

### Core Data Errors

1. **Clean Build**: Product → Clean Build Folder
2. **Delete App**: Remove from device/simulator
3. **Fresh Install**: Rebuild and reinstall

## Credits

Built with:
- SwiftUI for declarative UI
- Multipeer Connectivity for networking
- Core Data for persistence
- AVFoundation for audio
- GameController framework (future integration)

## License

This is a prototype/demonstration project for educational purposes.

---

**Version**: 1.0
**Platform**: tvOS 15.0+
**Language**: Swift 5.7+
**Framework**: SwiftUI
