//
//  CRUD_Demo_SwiftUIApp.swift
//  CRUD_Demo_SwiftUI
//
//  Created by vignesh kumar c on 13/09/23.
//

import SwiftUI

@main
struct CRUD_Demo_SwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
