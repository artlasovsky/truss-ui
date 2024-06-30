//
//  Spacing.swift
//  
//
//  Created by Art Lasovsky on 27/06/2024.
//

import Foundation

extension FoundationUI.DefaultTheme {
    public var spacing: Token.Spacing { .init(base: baseValue) }
}

public extension FoundationUI.DefaultTheme.Token {
    struct Spacing: FoundationDefaultThemeMultiplierToken {
        public let value: Configuration
        
        public init(_ value: Value) {
            self.value = value
        }
        
        public struct Scale: FoundationDefaultThemeMultiplierTokenDefaults {
            public var adjust: (SourceValue) -> ResultValue
            public init(_ adjust: @escaping (SourceValue) -> ResultValue) {
                self.adjust = adjust
            }
        }
    }
}