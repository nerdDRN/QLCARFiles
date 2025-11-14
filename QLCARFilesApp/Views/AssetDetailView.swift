//
//  AssetDetailView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct AssetDetailView: View {
    let asset: GroupedAsset

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(asset.baseName)
                            .font(.title)

                        Spacer()

                        Button(action: {
                            ExportHelper.exportAsset(asset)
                        }) {
                            Label(.localizable(.export), systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)

                        Text(asset.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }

                    Text(.localizable(.variantCount(asset.variants.count)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                Divider()

                // Content based on type
                switch asset.type {
                case .images:
                    ImageAssetView(asset: asset)
                case .colors:
                    ColorAssetView(asset: asset)
                case .data:
                    DataAssetView(asset: asset)
                case .all:
                    Text(.localizable(.mixedAssetType))
                        .foregroundColor(.secondary)
                        .padding()
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
