//
//  ContentView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AssetManager()
    @State private var selectedAsset: GroupedAsset?

    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView(viewModel: viewModel, selectedAsset: $selectedAsset)
        } detail: {
            // Detail view
            if viewModel.isLoading {
                ProgressView(.localizable(.loadingCarFile))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let asset = selectedAsset {
                AssetDetailView(asset: asset)
            } else if viewModel.assets.isEmpty {
                WelcomeView()
            } else {
                Text(.localizable(.selectAsset))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(viewModel.carFilePath.map { URL(fileURLWithPath: $0).lastPathComponent } ?? String(localizable: .carViewer))
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel.openCARFile()
                } label: {
                    Label(String(localizable: .openLabel), systemImage: "folder")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    let fileName = viewModel.carFilePath.map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent } ?? "assets"
                    ExportHelper.exportAllAssets(viewModel.assets, carFileName: fileName)
                } label: {
                    Label(String(localizable: .exportAll), systemImage: "square.and.arrow.down.on.square")
                }
                .disabled(viewModel.assets.isEmpty)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openCARFile)) { _ in
            viewModel.openCARFile()
        }
    }
}


#Preview {
    ContentView()
}
