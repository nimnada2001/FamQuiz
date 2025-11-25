//
//  PersistenceController.swift
//  Multi-User Family Quiz Arena
//
//  Core Data stack setup and management
//  Handles local persistence of game history and player scores
//

import CoreData

/// Manages Core Data stack for persisting game data
struct PersistenceController {
    // Singleton instance for app-wide access
    static let shared = PersistenceController()

    // Preview instance with in-memory store for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample data for preview
        for i in 0..<5 {
            let gameSession = GameSession(context: viewContext)
            gameSession.id = UUID()
            gameSession.date = Date().addingTimeInterval(-Double(i) * 86400)
            gameSession.numberOfPlayers = Int16(2 + i % 3)
            gameSession.numberOfQuestions = 10

            // Create sample player results
            for j in 0..<Int(gameSession.numberOfPlayers) {
                let result = PlayerResult(context: viewContext)
                result.id = UUID()
                result.playerName = "Player \(j + 1)"
                result.score = Int32(500 - j * 100)
                result.correctAnswers = Int16(5 - j)
                result.gameSession = gameSession
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    /// Initialize Core Data stack
    /// - Parameter inMemory: If true, creates an in-memory store (for testing/previews)
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FamilyQuiz")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this error appropriately
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }

        // Automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Save the current context if there are changes
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// Delete a game session and all related player results
    func deleteGameSession(_ gameSession: GameSession) {
        let context = container.viewContext
        context.delete(gameSession)
        save()
    }

    /// Fetch all game sessions sorted by date (newest first)
    func fetchGameSessions() -> [GameSession] {
        let request: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GameSession.date, ascending: false)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching game sessions: \(error)")
            return []
        }
    }

    /// Save a completed game session to Core Data
    func saveGameSession(players: [Player], numberOfQuestions: Int) {
        let context = container.viewContext

        let gameSession = GameSession(context: context)
        gameSession.id = UUID()
        gameSession.date = Date()
        gameSession.numberOfPlayers = Int16(players.count)
        gameSession.numberOfQuestions = Int16(numberOfQuestions)

        // Calculate total duration (placeholder - would be tracked in real implementation)
        gameSession.duration = 0

        // Save each player's results
        for player in players {
            let result = PlayerResult(context: context)
            result.id = UUID()
            result.playerName = player.name
            result.score = Int32(player.score)
            result.avatar = player.avatar
            // Calculate correct answers from score (assuming 100 points per correct answer)
            result.correctAnswers = Int16(player.score / 100)
            result.gameSession = gameSession
        }

        save()
    }
}
