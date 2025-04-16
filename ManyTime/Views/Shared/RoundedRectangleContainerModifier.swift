//
//  RoundedRectangleContainerModifier.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/16.
//

import SwiftUI

struct RoundedBorderContainerModifier: ViewModifier {
    var cornerRadius: CGFloat = 15
    var lineWidth: CGFloat = 1
    var shadowRadius: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: lineWidth)
            )
            .shadow(radius: shadowRadius)
    }
}

// Extension to make it easier to use
extension View {
    func roundedBorder(
        cornerRadius: CGFloat = 15,
        lineWidth: CGFloat = 1,
        shadowRadius: CGFloat = 0
    ) -> some View {
        self.modifier(RoundedBorderContainerModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            shadowRadius: shadowRadius
        ))
    }
}
