//
//  DataVariantView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI
import PDFKit

struct DataVariantView: View {
    let variant: AssetVariant
    let data: Data

    @State private var pdfDocument: PDFDocument?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(.localizable(.dataAsset))
                    .font(.headline)

                Spacer()

                Text("\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Try to display PDF preview
            if let pdf = pdfDocument, pdf.pageCount > 0 {
                PDFPreviewView(document: pdf)
                    .frame(height: 300)
            } else {
                HStack {
                    Image(systemName: "doc")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(.localizable(.binaryData))
                            .font(.headline)

                        Text(.localizable(.bytesCount(data.count)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(40)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .onAppear {
            pdfDocument = PDFDocument(data: data)
        }
    }
}
