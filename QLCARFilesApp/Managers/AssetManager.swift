//
//  AssetManager.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import Foundation
import SwiftUI
import AppKit

@MainActor
class AssetManager: ObservableObject {
    @Published var assets: [GroupedAsset] = [] {
        didSet {
            updateAssetCounts()
        }
    }
    @Published var selectedType: AssetType = .all
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var carFilePath: String?
    @Published var assetCounts: [AssetType: Int] = [:]

    private let logger = AppLogger.parser

    var filteredAssets: [GroupedAsset] {
        if selectedType == .all {
            return assets
        }
        return assets.filter { $0.type == selectedType }
    }

    private func updateAssetCounts() {
        var counts: [AssetType: Int] = [:]
        for type in AssetType.allCases {
            if type == .all {
                counts[type] = assets.count
            } else {
                counts[type] = assets.filter { $0.type == type }.count
            }
        }
        assetCounts = counts
    }

    func openCARFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.init(filenameExtension: "car")].compactMap { $0 }
        panel.message = "Select an Assets.car file"

        if panel.runModal() == .OK, let url = panel.url {
            loadCARFile(at: url.path)
        }
    }

    func loadCARFile(at path: String) {
        logger.info("Loading CAR file at path: \(path)")
        isLoading = true
        errorMessage = nil
        carFilePath = path
        assets.removeAll()

        Task {
            await loadAssetsFromCAR(path: path)
            isLoading = false
        }
    }

    private func loadAssetsFromCAR(path: String) async {
        var tempAssets: [String: [AssetVariant]] = [:]

        let success = ProcessCarFileAtPath(path, nil) { _, assetDict in
            guard let fileName = assetDict?[kCarInfoDict_FilenameKey] as? String else { return }

            // Parse the asset
            let variant = self.parseAssetVariant(from: assetDict!, fileName: fileName)

            // Extract base name
            let baseName = self.extractBaseName(from: fileName)

            // Group by base name
            if tempAssets[baseName] == nil {
                tempAssets[baseName] = []
            }
            if let wrappedVariants = variant {
                tempAssets[baseName]?.append(wrappedVariants)
            }
        }

        if !success {
            logger.error("Failed to load CAR file at path: \(path)")
            await MainActor.run {
                self.errorMessage = "Failed to load CAR file"
            }
            return
        }

        logger.info("Successfully parsed CAR file, found \(tempAssets.count) assets")

        // Convert to GroupedAssets
        var groupedAssets: [GroupedAsset] = []

        for (baseName, variants) in tempAssets {
            let type = determineAssetType(from: variants)
            let grouped = GroupedAsset(baseName: baseName, type: type, variants: variants)
            groupedAssets.append(grouped)
        }

        // Sort by name
        groupedAssets.sort { $0.baseName < $1.baseName }

        await MainActor.run {
            self.assets = groupedAssets
            logger.info("Loaded \(groupedAssets.count) grouped assets")
        }
    }

    private func parseAssetVariant(from dict: [String: Any], fileName: String) -> AssetVariant? {
        // Determine scale
        let scale: AssetVariant.Scale
        if fileName.contains("@3x") {
            scale = .x3
        } else if fileName.contains("@2x") {
            scale = .x2
        } else {
            scale = .x1
        }

        // Determine appearance
        let appearance: AssetVariant.Appearance
        if fileName.contains("~UIAppearanceDark") || fileName.contains("~Dark") {
            appearance = .dark
        } else if fileName.contains("~UIAppearanceLight") || fileName.contains("~Light") {
            appearance = .light
        } else {
            appearance = .any
        }

        // Get image - NSImage is created in Objective-C to ensure proper memory management
        let image = dict[kCarInfoDict_NSImageKey] as? NSImage
        if image == nil {
            return nil
        }

        // Get color hex
        let colorHex = dict[kCarInfoDict_DescriptionKey] as? String

        // Get data
        let data = dict[kCarInfoDict_DataKey] as? Data

        // Get NSColor if available
        var nsColor: NSColor?
        if let hex = colorHex {
            nsColor = NSColor(hex: hex)
        }

        return AssetVariant(
            scale: scale,
            appearance: appearance,
            image: image,
            color: nsColor,
            data: data,
            colorHex: colorHex
        )
    }

    private func extractBaseName(from fileName: String) -> String {
        var base = fileName

        // Remove file extension
        if let dotRange = base.lastIndex(of: ".") {
            base = String(base[..<dotRange])
        }

        // Remove appearance suffix
        if let range = base.range(of: "~UIAppearance") {
            base = String(base[..<range.lowerBound])
        }

        // Remove scale suffix
        if let range = base.range(of: "@") {
            base = String(base[..<range.lowerBound])
        }

        // Remove other suffixes
        let suffixes = ["~Any", "~Light", "~Dark", "~phone", "~pad", "~watch", "~tv"]
        for suffix in suffixes {
            if let range = base.range(of: suffix) {
                base = String(base[..<range.lowerBound])
            }
        }

        return base
    }

    private func determineAssetType(from variants: [AssetVariant]) -> AssetType {
        // Check first variant to determine type
        guard let first = variants.first else { return .data }

        if first.color != nil {
            return .colors
        } else if first.image != nil {
            return .images
        } else if first.data != nil {
            return .data
        }

        return .data
    }
}
