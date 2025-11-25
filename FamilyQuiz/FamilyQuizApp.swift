//
//  FamilyQuizApp.swift
//  Multi-User Family Quiz Arena
//
//  Main app entry point for tvOS application
//  Configures SwiftUI app lifecycle and Core Data stack
//

import SwiftUI
import CoreData

@main
struct FamilyQuizApp: App {
    // Core Data persistence controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
