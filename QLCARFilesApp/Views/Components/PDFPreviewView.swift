//
//  PDFPreviewView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let document: PDFDocument

    var body: some View {
        Group {
            if let page = document.page(at: 0) {
                GeometryReader { geometry in
                    PDFPageView(page: page, size: geometry.size)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
