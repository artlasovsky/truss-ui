//
//  ForegroundModifier.swift
//  
//
//  Created by Art Lasovsky on 03/06/2024.
//

import Foundation
import SwiftUI

public extension FoundationUIModifier where Self == FoundationUI.Modifier.ForegroundModifier {
    static func foreground(_ color: FoundationUI.Theme.Color) -> Self {
        .init(tint: color, scale: nil)
    }
    
    static func foregroundTinted(_ scale: FoundationUI.Theme.Color.Scale) -> Self {
        .init(tint: nil, scale: scale)
    }
}

public extension FoundationUI.Modifier {
    struct ForegroundModifier: FoundationUIModifier {
        @Environment(\.dynamicColorTint) private var environmentTint
        let tint: FoundationUI.DynamicColor?
        let scale: FoundationUI.DynamicColor.Scale?
        
        private var color: FoundationUI.DynamicColor {
            let tint = tint ?? environmentTint
            if let scale {
                return tint.scale(scale)
            }
            return tint
        }
        
        public func body(content: Content) -> some View {
            content.foregroundStyle(color)
        }
    }
}


#Preview {
    VStack {
        Text("Foreground")
            .foundation(.foreground(.red))
        Text("Foreground")
            .foundation(.foregroundTinted(.text))
            .foundation(.tint(.red))
    }
    .padding()
}