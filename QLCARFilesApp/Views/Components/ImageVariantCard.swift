//
//  ImageVariantCard.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct ImageVariantCard: View {
    let variant: AssetVariant
    let scale: AssetVariant.Scale
    let backgroundStyle: BackgroundStyle

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 12) {
            // Image
            ZStack {
                // Background for transparency
                BackgroundView(style: backgroundStyle)
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)

                if let nsImage = variant.image {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovered ? 0.2 : 0.1), radius: 4)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)

            // Scale label
            VStack(spacing: 4) {
                Text(scale.displayName)
                    .font(.caption)
                    .fontWeight(.medium)

                if let nsImage = variant.image {
                    Text(.localizable(.dimensions(Int(nsImage.size.width), Int(nsImage.size.height))))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
