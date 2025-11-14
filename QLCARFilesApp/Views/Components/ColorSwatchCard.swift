//
//  ColorSwatchCard.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct ColorSwatchCard: View {
    let variant: AssetVariant
    let title: String

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 16) {
            // Color swatch
            ZStack {
                if let color = variant.color {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(color))
                        .frame(width: 140, height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(isHovered ? 0.2 : 0.1), radius: 8)
                        .scaleEffect(isHovered ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                }
            }

            // Labels
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                if let hex = variant.colorHex {
                    Text(hex)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
