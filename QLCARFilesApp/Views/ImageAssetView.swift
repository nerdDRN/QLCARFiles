//
//  ImageAssetView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct ImageAssetView: View {
    let asset: GroupedAsset

    @State private var backgroundStyle: BackgroundStyle = .checkerboard

    // Group variants by appearance
    private var appearanceGroups: [(appearance: AssetVariant.Appearance, variants: [AssetVariant])] {
        let grouped = Dictionary(grouping: asset.variants) { $0.appearance }
        let sorted = grouped.sorted { $0.key.rawValue < $1.key.rawValue }
        return sorted.map { (appearance: $0.key, variants: $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Background picker
            HStack {
                Text(.localizable(.backgroundLabel))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker(.localizable(.background), selection: $backgroundStyle) {
                    ForEach(BackgroundStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 400)

                Spacer()
            }
            .padding(.horizontal)

            ForEach(appearanceGroups, id: \.appearance) { group in
                VStack(alignment: .leading, spacing: 16) {
                    // Appearance header
                    Text(group.appearance.displayName)
                        .font(.headline)
                        .padding(.horizontal)

                    // Scale variants
                    HStack(alignment: .top, spacing: 40) {
                        ForEach(AssetVariant.Scale.allCases, id: \.self) { scale in
                            if let variant = group.variants.first(where: { $0.scale == scale }) {
                                ImageVariantCard(variant: variant, scale: scale, backgroundStyle: backgroundStyle)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Universal label if only one appearance
            if appearanceGroups.count == 1 {
                HStack {
                    Spacer()
                    Text(.localizable(.universal))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
