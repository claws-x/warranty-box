//
//  WarrantyBoxApp.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import SwiftUI

@main
struct WarrantyBoxApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
