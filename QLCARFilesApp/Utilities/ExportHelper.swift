//
//  ExportHelper.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import Foundation
import AppKit
import PDFKit
import UniformTypeIdentifiers

class ExportHelper {

    private nonisolated(unsafe) static let logger = AppLogger.export

    // MARK: - Export Single Asset

    /// Export a single grouped asset
    /// If asset has multiple variants, creates a ZIP file
    /// If asset has single variant, exports directly
    @MainActor
    static func exportAsset(_ asset: GroupedAsset) {
        let variantText = String(localizable: .variantCount(asset.variants.count))
        logger.info("Exporting asset: \(asset.baseName) with \(variantText)")
        if asset.variants.count == 1 {
            // Single variant - export directly
            exportSingleVariant(asset: asset, variant: asset.variants[0])
        } else {
            // Multiple variants - export as ZIP
            exportAssetAsZip(asset)
        }
    }

    /// Export all assets from the view model
    @MainActor
    static func exportAllAssets(_ assets: [GroupedAsset], carFileName: String) {
        logger.info("Starting export of all assets (\(assets.count) total)")
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.zip]
        panel.nameFieldStringValue = "\(carFileName)_export.zip"
        panel.message = "Export All Assets as ZIP"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                logger.info("Export cancelled by user")
                return
            }

            do {
                try createZipWithAllAssets(assets: assets, zipURL: url)
                logger.info("Successfully exported \(assets.count) assets to: \(url.path)")
                showSuccess(message: "Successfully exported \(assets.count) asset(s) to:\n\(url.path)")
            } catch {
                logger.error("Failed to export all assets", error: error)
                showError(message: "Failed to create ZIP: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Export Methods

    @MainActor
    private static func exportSingleVariant(asset: GroupedAsset, variant: AssetVariant) {
        let panel = NSSavePanel()

        // Determine file extension based on asset type
        var ext = "png"
        switch asset.type {
        case .images:
            ext = "png"
            panel.allowedContentTypes = [.png]
        case .colors:
            ext = "png"
            panel.allowedContentTypes = [.png]
        case .data:
            // Try to detect data type
            if let data = variant.data {
                if PDFDocument(data: data) != nil {
                    ext = "pdf"
                    panel.allowedContentTypes = [.pdf]
                } else if NSImage(data: data) != nil {
                    ext = "png"
                    panel.allowedContentTypes = [.png]
                } else {
                    ext = "dat"
                    panel.allowedContentTypes = [.data]
                }
            }
        case .all:
            ext = "dat"
            panel.allowedContentTypes = [.data]
        }

        panel.nameFieldStringValue = "\(asset.baseName).\(ext)"
        panel.message = "Export \(asset.baseName)"

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            do {
                try exportVariantToFile(variant: variant, assetType: asset.type, url: url)
                showSuccess(message: "Successfully exported to:\n\(url.path)")
            } catch {
                showError(message: "Failed to export: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private static func exportAssetAsZip(_ asset: GroupedAsset) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.zip]
        panel.nameFieldStringValue = "\(asset.baseName).zip"
        panel.message = "Export \(asset.baseName) (all variants)"

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            do {
                try createZipWithAsset(asset: asset, zipURL: url)
                let message = String(localizable: .variantsExported(asset.variants.count, url.path))
                showSuccess(message: message)
            } catch {
                showError(message: "Failed to create ZIP: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - File Export

    private static func exportVariantToFile(variant: AssetVariant, assetType: AssetType, url: URL) throws {
        switch assetType {
        case .images:
            guard let image = variant.image else {
                throw ExportError.noImageData
            }
            try exportImageAsPNG(image: image, to: url)

        case .colors:
            guard let color = variant.color else {
                throw ExportError.noColorData
            }
            try exportColorAsPNG(color: color, to: url)

        case .data:
            guard let data = variant.data else {
                throw ExportError.noData
            }
            // Check if it's a PDF first, then image, otherwise raw data
            if PDFDocument(data: data) != nil {
                try data.write(to: url)
            } else if let image = NSImage(data: data) {
                try exportImageAsPNG(image: image, to: url)
            } else {
                try data.write(to: url)
            }

        case .all:
            throw ExportError.unsupportedType
        }
    }

    private static func exportImageAsPNG(image: NSImage, to url: URL) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            throw ExportError.pngConversionFailed
        }
        try pngData.write(to: url)
    }

    private static func exportColorAsPNG(color: NSColor, to url: URL) throws {
        let size = NSSize(width: 120, height: 120)
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()

        try exportImageAsPNG(image: image, to: url)
    }

    // MARK: - ZIP Creation

    private static func createZipWithAsset(asset: GroupedAsset, zipURL: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        // Export each variant to temp directory
        for variant in asset.variants {
            let fileName = buildFileName(baseName: asset.baseName, variant: variant, type: asset.type)
            let fileURL = tempDir.appendingPathComponent(fileName)
            try exportVariantToFile(variant: variant, assetType: asset.type, url: fileURL)
        }

        // Create ZIP
        try zipDirectory(at: tempDir, to: zipURL)
    }

    private static func createZipWithAllAssets(assets: [GroupedAsset], zipURL: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        // Export each asset
        for asset in assets {
            for variant in asset.variants {
                let fileName = buildFileName(baseName: asset.baseName, variant: variant, type: asset.type)
                let fileURL = tempDir.appendingPathComponent(fileName)
                try exportVariantToFile(variant: variant, assetType: asset.type, url: fileURL)
            }
        }

        // Create ZIP
        try zipDirectory(at: tempDir, to: zipURL)
    }

    private static func zipDirectory(at sourceURL: URL, to destinationURL: URL) throws {
        let coordinator = NSFileCoordinator()
        var error: NSError?

        coordinator.coordinate(readingItemAt: sourceURL, options: .forUploading, error: &error) { zipURL in
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: zipURL, to: destinationURL)
            } catch {
                print("Error creating zip: \(error)")
            }
        }

        if let error = error {
            throw error
        }
    }

    // MARK: - Helper Methods

    private static func buildFileName(baseName: String, variant: AssetVariant, type: AssetType) -> String {
        var fileName = baseName

        // Add scale suffix for images
        if type == .images && variant.scale != .x1 {
            fileName += "@\(variant.scale.rawValue)"
        }

        // Add appearance suffix
        if variant.appearance != .any {
            fileName += "~\(variant.appearance.rawValue)"
        }

        // Add extension
        switch type {
        case .images, .colors:
            fileName += ".png"
        case .data:
            // Check if it's a PDF, then image, otherwise dat
            if let data = variant.data {
                if PDFDocument(data: data) != nil {
                    fileName += ".pdf"
                } else if NSImage(data: data) != nil {
                    fileName += ".png"
                } else {
                    fileName += ".dat"
                }
            } else {
                fileName += ".dat"
            }
        case .all:
            fileName += ".dat"
        }

        return fileName
    }

    @MainActor
    private static func showError(message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @MainActor
    private static func showSuccess(message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Successful"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    // MARK: - Error Types

    enum ExportError: LocalizedError {
        case noImageData
        case noColorData
        case noData
        case pngConversionFailed
        case unsupportedType

        var errorDescription: String? {
            switch self {
            case .noImageData: return "No image data available"
            case .noColorData: return "No color data available"
            case .noData: return "No data available"
            case .pngConversionFailed: return "Failed to convert image to PNG"
            case .unsupportedType: return "Unsupported asset type"
            }
        }
    }
}
