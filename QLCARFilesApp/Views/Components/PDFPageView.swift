//
//  PDFPageView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI
import PDFKit
import AppKit

struct PDFPageView: View {
    let page: PDFPage
    let size: CGSize

    var body: some View {
        GeometryReader { geometry in
            if let image = renderPDFPageToImage(page: page, targetSize: geometry.size) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                Text(.localizable(.unableToRenderPdf))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func renderPDFPageToImage(page: PDFPage, targetSize: CGSize) -> NSImage? {
        let pageBounds = page.bounds(for: .mediaBox)

        // Calculate scale to fit
        let scaleX = targetSize.width / pageBounds.width
        let scaleY = targetSize.height / pageBounds.height
        let scale = min(scaleX, scaleY) * 0.9

        let scaledWidth = pageBounds.width * scale
        let scaledHeight = pageBounds.height * scale

        let image = NSImage(size: NSSize(width: scaledWidth, height: scaledHeight))
        image.lockFocus()

        if let context = NSGraphicsContext.current?.cgContext {
            context.setFillColor(NSColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: NSSize(width: scaledWidth, height: scaledHeight)))

            context.translateBy(x: 0, y: scaledHeight)
            context.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: context)
        }

        image.unlockFocus()
        return image
    }
}
