//
//  DataAssetView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI
import PDFKit

struct DataAssetView: View {
    let asset: GroupedAsset

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(asset.variants) { variant in
                if let data = variant.data {
                    DataVariantView(variant: variant, data: data)
                }
            }
        }
        .padding()
    }
}
