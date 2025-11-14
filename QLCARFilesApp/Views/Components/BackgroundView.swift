//
//  BackgroundView.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import SwiftUI

struct BackgroundView: View {
    let style: BackgroundStyle
    let squareSize: CGFloat = 8

    var body: some View {
        switch style {
        case .checkerboard:
            checkerboardPattern
        case .dark:
            Color(white: 0.3)
        case .black:
            Color.black
        case .light:
            Color(white: 0.9)
        case .white:
            Color.white
        }
    }

    private var checkerboardPattern: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let rows = Int(size.height / squareSize) + 1
                let cols = Int(size.width / squareSize) + 1

                for row in 0..<rows {
                    for col in 0..<cols {
                        let isEven = (row + col) % 2 == 0
                        let rect = CGRect(
                            x: CGFloat(col) * squareSize,
                            y: CGFloat(row) * squareSize,
                            width: squareSize,
                            height: squareSize
                        )

                        context.fill(
                            Path(rect),
                            with: .color(isEven ? .white : Color(white: 0.9))
                        )
                    }
                }
            }
        }
    }
}
