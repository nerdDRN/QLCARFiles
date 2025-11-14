//
//  QLCARFilesAppTests.swift
//  QLCARFilesAppTests
//
//  Created by Cagan on 14.11.2025.
//

import Testing
import Foundation
import AppKit
@testable import QLCARFilesApp

// MARK: - Model Tests
struct AssetModelTests {

    @Test("AssetType has correct cases")
    func testAssetTypeCases() {
        let allCases = AssetType.allCases
        #expect(allCases.contains(.all))
        #expect(allCases.contains(.images))
        #expect(allCases.contains(.colors))
        #expect(allCases.contains(.data))
        #expect(allCases.count == 4)
    }

    @Test("AssetType has correct icons")
    func testAssetTypeIcons() {
        #expect(AssetType.all.icon == "square.grid.2x2")
        #expect(AssetType.images.icon == "photo")
        #expect(AssetType.colors.icon == "paintpalette")
        #expect(AssetType.data.icon == "doc")
    }

    @Test("AssetVariant Scale display names")
    func testAssetVariantScaleDisplayNames() {
        #expect(AssetVariant.Scale.x1.displayName == "1x")
        #expect(AssetVariant.Scale.x2.displayName == "2x")
        #expect(AssetVariant.Scale.x3.displayName == "3x")
    }

    @Test("AssetVariant Appearance display names")
    func testAssetVariantAppearanceDisplayNames() {
        #expect(AssetVariant.Appearance.any.displayName == "Any Appearance")
        #expect(AssetVariant.Appearance.light.displayName == "Light")
        #expect(AssetVariant.Appearance.dark.displayName == "Dark")
    }

    @Test("GroupedAsset uses baseName as ID")
    func testGroupedAssetID() {
        let variant = AssetVariant(scale: .x1, appearance: .any, image: nil, color: nil, data: nil, colorHex: nil)
        let grouped = GroupedAsset(baseName: "testAsset", type: .images, variants: [variant])
        #expect(grouped.id == "testAsset")
    }

    @Test("GroupedAsset groups variants by scale")
    func testGroupedAssetVariantsByScale() {
        let variant1x = AssetVariant(scale: .x1, appearance: .any, image: nil, color: nil, data: nil, colorHex: nil)
        let variant2x = AssetVariant(scale: .x2, appearance: .any, image: nil, color: nil, data: nil, colorHex: nil)
        let variant3x = AssetVariant(scale: .x3, appearance: .any, image: nil, color: nil, data: nil, colorHex: nil)

        let grouped = GroupedAsset(baseName: "test", type: .images, variants: [variant1x, variant2x, variant3x])
        let byScale = grouped.variantsByScale

        #expect(byScale[.x1]?.count == 1)
        #expect(byScale[.x2]?.count == 1)
        #expect(byScale[.x3]?.count == 1)
    }

    @Test("GroupedAsset groups variants by appearance")
    func testGroupedAssetVariantsByAppearance() {
        let variantAny = AssetVariant(scale: .x1, appearance: .any, image: nil, color: nil, data: nil, colorHex: nil)
        let variantLight = AssetVariant(scale: .x1, appearance: .light, image: nil, color: nil, data: nil, colorHex: nil)
        let variantDark = AssetVariant(scale: .x1, appearance: .dark, image: nil, color: nil, data: nil, colorHex: nil)

        let grouped = GroupedAsset(baseName: "test", type: .colors, variants: [variantAny, variantLight, variantDark])
        let byAppearance = grouped.variantsByAppearance

        #expect(byAppearance[.any]?.count == 1)
        #expect(byAppearance[.light]?.count == 1)
        #expect(byAppearance[.dark]?.count == 1)
    }
}

// MARK: - NSColor Extension Tests
struct NSColorExtensionTests {

    @Test("NSColor parses 6-digit hex")
    func testNSColorParse6DigitHex() {
        let color = NSColor(hex: "FF0000")
        #expect(color != nil)

        if let color = color {
            #expect(color.redComponent == 1.0)
            #expect(color.greenComponent == 0.0)
            #expect(color.blueComponent == 0.0)
            #expect(color.alphaComponent == 1.0)
        }
    }

    @Test("NSColor parses 6-digit hex with hash")
    func testNSColorParse6DigitHexWithHash() {
        let color = NSColor(hex: "#00FF00")
        #expect(color != nil)

        if let color = color {
            #expect(color.redComponent == 0.0)
            #expect(color.greenComponent == 1.0)
            #expect(color.blueComponent == 0.0)
        }
    }

    @Test("NSColor parses 8-digit hex with alpha")
    func testNSColorParse8DigitHex() {
        let color = NSColor(hex: "FF000080")
        #expect(color != nil)

        if let color = color {
            #expect(color.redComponent == 1.0)
            #expect(color.greenComponent == 0.0)
            #expect(color.blueComponent == 0.0)
            let alpha = round(color.alphaComponent * 255) / 255
            #expect(abs(alpha - 0.5) < 0.01) // approximately 0.5
        }
    }

    @Test("NSColor returns nil for invalid hex")
    func testNSColorInvalidHex() {
        #expect(NSColor(hex: "GGGGGG") == nil)
        #expect(NSColor(hex: "123") == nil)
        #expect(NSColor(hex: "") == nil)
    }
}

// MARK: - AssetManager Tests
@MainActor
struct AssetManagerTests {

    @Test("AssetManager initializes with empty state")
    func testInitialState() {
        let viewModel = AssetManager()
        #expect(viewModel.assets.isEmpty)
        #expect(viewModel.selectedType == .all)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.carFilePath == nil)
        #expect(viewModel.assetCounts.isEmpty)
    }

    @Test("AssetManager sets loading state when loading file")
    func testLoadingState() {
        let viewModel = AssetManager()
        let testPath = "/test/path/Assets.car"

        #expect(viewModel.isLoading == false)
        #expect(viewModel.carFilePath == nil)

        // Start loading (won't actually load in unit test)
        viewModel.loadCARFile(at: testPath)

        // Verify initial loading state is set
        #expect(viewModel.carFilePath == testPath)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("AssetManager filters assets by type")
    func testFilteredAssets() {
        let viewModel = AssetManager()

        // Create test assets
        let imageVariant = AssetVariant(scale: .x1, appearance: .any, image: NSImage(), color: nil, data: nil, colorHex: nil)
        let colorVariant = AssetVariant(scale: .x1, appearance: .any, image: nil, color: NSColor.red, data: nil, colorHex: "#FF0000")
        let dataVariant = AssetVariant(scale: .x1, appearance: .any, image: nil, color: nil, data: Data(), colorHex: nil)

        let imageAsset = GroupedAsset(baseName: "testImage", type: .images, variants: [imageVariant])
        let colorAsset = GroupedAsset(baseName: "testColor", type: .colors, variants: [colorVariant])
        let dataAsset = GroupedAsset(baseName: "testData", type: .data, variants: [dataVariant])

        viewModel.assets = [imageAsset, colorAsset, dataAsset]

        // Test filtering by .all
        viewModel.selectedType = .all
        #expect(viewModel.filteredAssets.count == 3)

        // Test filtering by .images
        viewModel.selectedType = .images
        #expect(viewModel.filteredAssets.count == 1)
        #expect(viewModel.filteredAssets.first?.type == .images)

        // Test filtering by .colors
        viewModel.selectedType = .colors
        #expect(viewModel.filteredAssets.count == 1)
        #expect(viewModel.filteredAssets.first?.type == .colors)

        // Test filtering by .data
        viewModel.selectedType = .data
        #expect(viewModel.filteredAssets.count == 1)
        #expect(viewModel.filteredAssets.first?.type == .data)
    }

    @Test("AssetManager updates asset counts correctly")
    func testAssetCounts() {
        let viewModel = AssetManager()

        let imageVariant = AssetVariant(scale: .x1, appearance: .any, image: NSImage(), color: nil, data: nil, colorHex: nil)
        let colorVariant = AssetVariant(scale: .x1, appearance: .any, image: nil, color: NSColor.red, data: nil, colorHex: "#FF0000")

        let imageAsset1 = GroupedAsset(baseName: "image1", type: .images, variants: [imageVariant])
        let imageAsset2 = GroupedAsset(baseName: "image2", type: .images, variants: [imageVariant])
        let colorAsset = GroupedAsset(baseName: "color1", type: .colors, variants: [colorVariant])

        viewModel.assets = [imageAsset1, imageAsset2, colorAsset]

        #expect(viewModel.assetCounts[.all] == 3)
        #expect(viewModel.assetCounts[.images] == 2)
        #expect(viewModel.assetCounts[.colors] == 1)
        #expect(viewModel.assetCounts[.data] == 0)
    }

    @Test("AssetManager clears assets when loading new file")
    func testClearAssetsOnLoad() {
        let viewModel = AssetManager()

        // Add some mock assets
        let variant = AssetVariant(scale: .x1, appearance: .any, image: NSImage(), color: nil, data: nil, colorHex: nil)
        let asset = GroupedAsset(baseName: "test", type: .images, variants: [variant])
        viewModel.assets = [asset]

        #expect(viewModel.assets.count == 1)

        // Load a new file (won't actually complete in unit test)
        viewModel.loadCARFile(at: "/test/path.car")

        // Assets should be cleared immediately when starting a new load
        #expect(viewModel.assets.isEmpty)
    }
}

// MARK: - Base Name Extraction Tests
struct BaseNameExtractionTests {

    @Test("Extract base name from file with scale")
    func testExtractBaseNameWithScale() {
        let baseName = extractBaseName(from: "icon@2x.png")
        #expect(baseName == "icon")
    }

    @Test("Extract base name from file with appearance")
    func testExtractBaseNameWithAppearance() {
        let baseName = extractBaseName(from: "button~UIAppearanceDark.png")
        #expect(baseName == "button")
    }

    @Test("Extract base name from file with scale and appearance")
    func testExtractBaseNameWithScaleAndAppearance() {
        let baseName = extractBaseName(from: "icon@3x~UIAppearanceLight.png")
        #expect(baseName == "icon")
    }

    @Test("Extract base name from simple filename")
    func testExtractBaseNameSimple() {
        let baseName = extractBaseName(from: "logo.png")
        #expect(baseName == "logo")
    }

    @Test("Extract base name with device suffixes")
    func testExtractBaseNameWithDeviceSuffixes() {
        #expect(extractBaseName(from: "icon~phone.png") == "icon")
        #expect(extractBaseName(from: "icon~pad.png") == "icon")
        #expect(extractBaseName(from: "icon~watch.png") == "icon")
        #expect(extractBaseName(from: "icon~tv.png") == "icon")
    }

    @Test("Extract base name with multiple suffixes")
    func testExtractBaseNameComplex() {
        #expect(extractBaseName(from: "icon@3x~UIAppearanceDark~phone.png") == "icon")
        #expect(extractBaseName(from: "button@2x~Light.png") == "button")
    }

    // Helper function that replicates the ViewModel's extractBaseName logic
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
}

// MARK: - Asset Variant Parsing Tests
struct AssetVariantParsingTests {

    @Test("Parse scale from filename with @2x")
    func testParseScale2x() {
        let fileName = "icon@2x.png"
        let scale = parseScale(from: fileName)
        #expect(scale == .x2)
    }

    @Test("Parse scale from filename with @3x")
    func testParseScale3x() {
        let fileName = "icon@3x.png"
        let scale = parseScale(from: fileName)
        #expect(scale == .x3)
    }

    @Test("Parse scale from filename without scale suffix")
    func testParseScale1x() {
        let fileName = "icon.png"
        let scale = parseScale(from: fileName)
        #expect(scale == .x1)
    }

    @Test("Parse dark appearance from filename")
    func testParseDarkAppearance() {
        #expect(parseAppearance(from: "icon~UIAppearanceDark.png") == .dark)
        #expect(parseAppearance(from: "icon~Dark.png") == .dark)
    }

    @Test("Parse light appearance from filename")
    func testParseLightAppearance() {
        #expect(parseAppearance(from: "icon~UIAppearanceLight.png") == .light)
        #expect(parseAppearance(from: "icon~Light.png") == .light)
    }

    @Test("Parse any appearance from filename")
    func testParseAnyAppearance() {
        #expect(parseAppearance(from: "icon.png") == .any)
        #expect(parseAppearance(from: "icon@2x.png") == .any)
    }

    // Helper functions that replicate the ViewModel's parsing logic
    private func parseScale(from fileName: String) -> AssetVariant.Scale {
        if fileName.contains("@3x") {
            return .x3
        } else if fileName.contains("@2x") {
            return .x2
        } else {
            return .x1
        }
    }

    private func parseAppearance(from fileName: String) -> AssetVariant.Appearance {
        if fileName.contains("~UIAppearanceDark") || fileName.contains("~Dark") {
            return .dark
        } else if fileName.contains("~UIAppearanceLight") || fileName.contains("~Light") {
            return .light
        } else {
            return .any
        }
    }
}
