//
//  ExampleApp.swift
//  Example
//
//  Created by Zaid Rahhawi on 4/8/24.
//

import SwiftUI
import SwiftData
import AppIntents
import Observation

@main
struct ExampleApp: App {
    private let service = HTTPGoRESTService(session: .example)
    private let modelContainer: ModelContainer
    private let router: Router
    
    init() {
        do {
            // MARK: - Initialize ModelContainer.
            let modelContainer = try ModelContainer(for: User.self, Post.self, Todo.self)
            self.modelContainer = modelContainer
            
            // MARK: Make ModelContainer available to App Intents.
            AppDependencyManager.shared.add(dependency: modelContainer)
            
            // MARK: - App Router
            let router = Router()
            self.router = router
            AppDependencyManager.shared.add(dependency: router)
        } catch {
            fatalError("Unable to configure SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
        .environment(router)
        .environment(\.service, service)
        .environment(\.handleError, HandleErrorAction(action: handle))
    }
    
    private func handle(error: Error) {
        print("Handling Error from ExampleApp: ", error)
    }
}
