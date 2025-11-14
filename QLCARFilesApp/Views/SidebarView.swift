//
//  SidebarView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: AssetManager
    @Binding var selectedAsset: GroupedAsset?
    @State private var selectedType: AssetType = .all

    var body: some View {
        VStack(spacing: 0) {
            // Type filter
            List(selection: $selectedType) {
                Section(.localizable(.assetTypes)) {
                    ForEach(AssetType.allCases) { type in
                        HStack {
                            Label {
                                Text(type.rawValue)
                            } icon: {
                                Image(systemName: type.icon)
                            }

                            Spacer()

                            if let count = viewModel.assetCounts[type] {
                                Text("\(count)")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .tag(type)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(height: 200)

            Divider()

            // Asset list
            List(selection: $selectedAsset) {
                Section(selectedType.rawValue) {
                    ForEach(viewModel.filteredAssets) { asset in
                        AssetListRow(asset: asset)
                            .tag(asset)
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 250)
        .onAppear {
            selectedType = viewModel.selectedType
        }
        .onChange(of: selectedType) { _, newValue in
            Task { @MainActor in
                viewModel.selectedType = newValue
            }
        }
    }
}
