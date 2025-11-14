//
//  AssetListRow.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct AssetListRow: View {
    let asset: GroupedAsset

    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Group {
                switch asset.type {
                case .images:
                    if let firstImage = asset.variants.first?.image {
                        Image(nsImage: firstImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "photo")
                    }
                case .colors:
                    if let firstColor = asset.variants.first?.color {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(firstColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                            )
                    } else {
                        Image(systemName: "paintpalette")
                    }
                case .data, .all:
                    Image(systemName: "doc")
                }
            }
            .frame(width: 24, height: 24)

            // Name
            Text(asset.baseName)
                .lineLimit(1)
        }
    }
}
