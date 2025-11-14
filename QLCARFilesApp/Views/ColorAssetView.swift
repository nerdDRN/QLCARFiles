//
//  ColorAssetView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct ColorAssetView: View {
    let asset: GroupedAsset

    private var colorVariants: [AssetVariant.Appearance: AssetVariant] {
        var dict: [AssetVariant.Appearance: AssetVariant] = [:]
        for variant in asset.variants {
            if variant.color != nil {
                dict[variant.appearance] = variant
            }
        }
        return dict
    }

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            // Color swatches
            HStack(spacing: 40) {
                if let variant = colorVariants[.any] {
                    ColorSwatchCard(
                        variant: variant,
                        title: "Light"
                    )
                }

                // Light Appearance
                if let variant = colorVariants[.light] {
                    ColorSwatchCard(
                        variant: variant,
                        title: "Light"
                    )
                }

                // Dark Appearance
                if let variant = colorVariants[.dark] {
                    ColorSwatchCard(
                        variant: variant,
                        title: "Dark"
                    )
                }
            }
            .padding(.horizontal, 40)

            // Universal label
            HStack {
                Spacer()
                Text(.localizable(.universal))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }

            Spacer()
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}
