//
//  WarrantyBoxApp.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import SwiftUI

@main
struct WarrantyBoxApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var dataController = DataController()
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(localization)
                .task {
                    NotificationManager.shared.fetchAuthorizationStatus { status in
                        guard status == .authorized || status == .provisional || status == .ephemeral else { return }
                        let items = dataController.fetchReminderEnabledItems()
                        NotificationManager.shared.refreshReminders(for: items)
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    NotificationManager.shared.fetchAuthorizationStatus { status in
                        guard status == .authorized || status == .provisional || status == .ephemeral else { return }
                        let items = dataController.fetchReminderEnabledItems()
                        NotificationManager.shared.refreshReminders(for: items)
                    }
                }
        }
    }
}
