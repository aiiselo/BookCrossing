//
//  BookCrossingApp.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 20.01.2022.
//

import SwiftUI
import Firebase

@main
struct BookCrossingApp: App {
    
    let persistenceController = PersistenceController.shared
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
