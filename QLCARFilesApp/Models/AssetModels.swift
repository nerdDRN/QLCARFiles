//
//  AssetType.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import Foundation
import CoreGraphics
import SwiftUI

// MARK: - Asset Type

enum AssetType: String, CaseIterable, Identifiable {
    case all = "All"
    case images = "Images"
    case colors = "Colors"
    case data = "Data"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .images: return "photo"
        case .colors: return "paintpalette"
        case .data: return "doc"
        }
    }
}

// MARK: - Asset Item

struct AssetItem: Identifiable {
    let id = UUID()
    let name: String
    let type: AssetType
    let variants: [AssetVariant]

    // Group by base name (without scale/appearance suffixes)
    var baseName: String {
        var base = name
        // Remove ~UIAppearanceAny, ~UIAppearanceDark, ~UIAppearanceLight
        if let range = base.range(of: "~UIAppearance") {
            base = String(base[..<range.lowerBound])
        }
        // Remove @2x, @3x
        if let range = base.range(of: "@") {
            base = String(base[..<range.lowerBound])
        }
        return base
    }
}

// MARK: - Asset Variant

struct AssetVariant: Identifiable, Hashable {
    let id = UUID()
    let scale: Scale
    let appearance: Appearance
    let image: NSImage?
    let color: NSColor?
    let data: Data?
    let colorHex: String?

    enum Scale: String, CaseIterable {
        case x1 = "1x"
        case x2 = "2x"
        case x3 = "3x"

        var displayName: String { rawValue }
    }

    enum Appearance: String, CaseIterable {
        case any = "Any Appearance"
        case light = "Light"
        case dark = "Dark"

        var displayName: String { rawValue }
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AssetVariant, rhs: AssetVariant) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Grouped Asset

struct GroupedAsset: Identifiable, Hashable {
    var id: String { baseName }
    let baseName: String
    let type: AssetType
    let variants: [AssetVariant]

    // Get variants by scale
    var variantsByScale: [AssetVariant.Scale: [AssetVariant]] {
        Dictionary(grouping: variants) { $0.scale }
    }

    // Get variants by appearance
    var variantsByAppearance: [AssetVariant.Appearance: [AssetVariant]] {
        Dictionary(grouping: variants) { $0.appearance }
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(baseName)
    }

    static func == (lhs: GroupedAsset, rhs: GroupedAsset) -> Bool {
        lhs.baseName == rhs.baseName
    }
}
