//
//  QLCARFilesAppApp.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

@main
struct QLCARFilesAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(.localizable(.openCarFile)) {
                    NotificationCenter.default.post(name: .openCARFile, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }
}
