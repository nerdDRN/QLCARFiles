//
//  WelcomeView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(.localizable(.welcomeTitle))
                .font(.title)

            Text(.localizable(.welcomeDescription))
                .foregroundColor(.secondary)

            Button(String(localizable: .openCarFile)) {
                NotificationCenter.default.post(name: .openCARFile, object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
