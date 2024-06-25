//
//  Theme.swift
//
//
//  Created by Art Lasovsky on 25/06/2024.
//

import Foundation
import SwiftUI

// MARK: - Default Theme Configuration
/// Extract to separate package,
/// but include it by default
///
/// `import FoundationUI` - Core + Default Theme
/// `import FoundationUICore` - Core only
///

extension FoundationUI {
    public struct Theme: ThemeConfiguration {
        public var baseValue: CGFloat
        
        public init(baseValue: CGFloat = 8) {
            self.baseValue = baseValue
        }
        public var padding: FoundationUI.Token.Padding { .init(baseValue) }
        public var spacing: FoundationUI.Token.Spacing { .init(baseValue / 2) }
//        public var radius:
        public var size: MultiplierScale { .init(baseValue, multiplier: 2)}
    }
}

public extension FoundationUITheme {
    public static var theme: FoundationUI.Theme { .init() }
}

// MARK: - Theme Protocols

public protocol ThemeConfiguration {
    associatedtype Padding = FoundationToken
    associatedtype Spacing = FoundationToken
    associatedtype Size = FoundationToken
    associatedtype Radius = FoundationToken
    var padding: Padding { get }
    var spacing: Spacing { get }
    var size: Size { get }
//    var radius: Radius { get }
}

public protocol FoundationUITheme {
    associatedtype Theme = ThemeConfiguration
    static var theme: Theme { get }
}

extension FoundationUI: FoundationUITheme {}

// MARK: - Token Protocol

public protocol FoundationToken {
    associatedtype Base
    associatedtype Result
    associatedtype Scale: FoundationTokenScale
    var base: Base { get }
    
    init(_ base: Base)
    
    func callAsFunction(_ scale: Scale) -> Result
}

extension FoundationToken {
    public func callAsFunction(_ scale: Scale) -> Result where Scale.SourceValue == Base, Scale.ResultValue == Result {
        scale(base)
    }
}

// MARK: - Scale Protocol

public protocol FoundationTokenScale {
    associatedtype SourceValue
    associatedtype ResultValue
    var adjust: (SourceValue) -> ResultValue { get }
    
    func callAsFunction(_ base: SourceValue) -> ResultValue
    
    init(_ adjust: @escaping (SourceValue) -> ResultValue)
}

public protocol FoundationTokenSizeScale: FoundationTokenScale {
    static var xxSmall: Self { get }
    static var xSmall: Self { get }
    static var small: Self { get }
    static var regular: Self { get }
    static var large: Self { get }
    static var xLarge: Self { get }
    static var xxLarge: Self { get }
}

extension FoundationTokenScale {
    public func callAsFunction(_ base: SourceValue) -> ResultValue {
        adjust(base)
    }
    public init(value: ResultValue) {
        self.init({ _ in value })
    }
}

// MARK: - Tokens

extension FoundationUI {
    public enum Token {        
        public struct Padding: FoundationToken {
            public struct Configuration {
                let base: CGFloat
                var multiplier: CGFloat = 2
            }
            public func callAsFunction(_ scale: Scale) -> CGFloat {
                scale((base.base, base.multiplier))
            }
            
            public typealias Result = CGFloat
            
            public let base: Configuration
            
            public init(_ base: Base) {
                self.base = base
            }
            
            public init(_ base: CGFloat, multiplier: CGFloat = 2) {
                self.base = .init(base: base, multiplier: multiplier)
            }
            
            public struct Scale: MultiplierScaleDefault {
                public var adjust: ((CGFloat, CGFloat)) -> CGFloat
                public init(_ adjust: @escaping ((CGFloat, CGFloat)) -> CGFloat) {
                    self.adjust = adjust
                }
            }
        }
        
        public struct Spacing: FoundationToken {
            public typealias Result = CGFloat
            public let base: CGFloat
            
            public init(_ base: CGFloat) {
                self.base = base
            }
            
            public struct Scale: FoundationTokenScaleDefault {
                public var adjust: (CGFloat) -> CGFloat
                public init(_ adjust: @escaping (CGFloat) -> CGFloat) {
                    self.adjust = adjust
                }
            }
        }
    }
}


public protocol FoundationTokenScaleDefault: FoundationTokenScale where SourceValue == CGFloat, ResultValue == CGFloat {}

extension FoundationTokenScaleDefault {
    public static var xxSmall: Self { Self { $0 / 8 } }
    public static var xSmall: Self { Self { $0 / 4 } }
    public static var small: Self { Self { $0 / 2 } }
    public static var regular: Self { Self { $0 } }
    public static var large: Self { Self { $0 * 2 } }
    public static var xLarge: Self { Self { $0 * 4 } }
    public static var xxLarge: Self { Self { $0 * 8 } }
}

// MARK: - Multiplier Scale

public protocol MultiplierScaleDefault: FoundationTokenScale where SourceValue == (CGFloat, CGFloat), ResultValue == CGFloat {}

extension MultiplierScaleDefault {
    public static var xxSmall: Self { Self { $0 / pow($1, 3) } }
    public static var xSmall: Self { Self { $0 / pow($1, 2) } }
    public static var small: Self { Self { $0 / $1 } }
    public static var regular: Self { Self { base, _ in base } }
    public static var large: Self { Self { $0 * $1 } }
    public static var xLarge: Self { Self { $0 * pow($1, 2) } }
    public static var xxLarge: Self { Self { ($0 * pow($1, 3)) } }
}

public struct MultiplierScale: FoundationToken {
    public func callAsFunction(_ scale: Scale) -> CGFloat {
        scale((base, multiplier)).precise(1)
    }
    
    public let base: CGFloat
    public let multiplier: CGFloat
    
    public init(_ base: CGFloat) {
        self.base = base
        self.multiplier = 2
    }
    
    public init(_ base: CGFloat, multiplier: CGFloat) {
        self.base = base
        self.multiplier = multiplier
    }
    
    public struct Scale: MultiplierScaleDefault {
        public var adjust: ((CGFloat, CGFloat)) -> CGFloat
        public init(_ adjust: @escaping ((CGFloat, CGFloat)) -> CGFloat) {
            self.adjust = adjust
        }
    }
}

// MARK: - Font Scale

extension FoundationUI.Token {
    // Mixed Types (Input - Output)
    public struct Font: FoundationToken {
        public typealias Result = SwiftUI.Font
        
        public var base: CGFloat
        
        public init(_ base: CGFloat) {
            self.base = base
        }
        
        public struct Scale: FoundationTokenScale {
            public var adjust: (CGFloat) -> SwiftUI.Font

            public init(_ adjust: @escaping (CGFloat) -> SwiftUI.Font) {
                self.adjust = adjust
            }
            
            public static var xxSmall = Self { .system(size: ($0 / 1.25).precise(1)) } // 8
            public static var xSmall = Self { .system(size: ($0 / 1.125).precise(1)) } // 10
            public static var small = Self { .system(size: ($0 / 1.05).precise(1)) } // 12
            public static let regular = Self(value: .system(size: 13))
            public static let large = Self(value: .title3)
            public static let xLarge = Self(value: .title2)
            public static let xxLarge = Self(value: .title)
        }
    }
    
    
    // With Config
    public struct Border: FoundationToken {
        public struct BorderConfig {
            let color: Color
            let width: CGFloat
        }
        public typealias Result = BorderConfig
        
        public var base: BorderConfig
        
        public init(_ base: BorderConfig) {
            self.base = base
        }
        
        public struct Scale: FoundationTokenScale {
            public var adjust: (BorderConfig) -> BorderConfig

            public init(_ adjust: @escaping (BorderConfig) -> BorderConfig) {
                self.adjust = adjust
            }
            
            public static var xxSmall = Self(value: .init(color: .blue, width: 1))
            public static var xSmall = Self(value: .init(color: .blue, width: 1))
            public static var small = Self(value: .init(color: .blue, width: 1))
            public static let regular = Self(value: .init(color: .blue, width: 1))
            public static let large = Self(value: .init(color: .blue, width: 1))
            public static let xLarge = Self(value: .init(color: .blue, width: 1))
            public static let xxLarge = Self(value: .init(color: .blue, width: 1))
        }
    }
    
//    public struct Color: FoundationToken {
//        public typealias Result = FoundationUI.DynamicColor
//        
//        public var base: FoundationUI.DynamicColor
//        
////        struct Scale:
//    }
}

// FoundationUI.theme.padding(.large) // scale
// FoundationUI.theme.padding.window // fixed
// or          .theme.padding(.window) ?
// View.foundation(.padding(.large))

#Preview {
    VStack {
        Text("Hello!").font(FoundationUI.Token.Font(13)(.xxSmall))
        Text("Hello!").font(FoundationUI.Token.Font(13)(.xSmall))
        Text("Hello!").font(FoundationUI.Token.Font(13)(.small))
        Text("Hello!").font(FoundationUI.Token.Font(13)(.regular))
            .border(FoundationUI.Token.Border(.init(color: .red, width: 2))(.regular).color)
        Text(MultiplierScale(9, multiplier: 1.5)(.xSmall).description)
        Text(MultiplierScale(9, multiplier: 1.5)(.small).description)
        Text(MultiplierScale(9, multiplier: 1.5)(.regular).description)
        Text(MultiplierScale(9, multiplier: 1.5)(.large).description)
        Text(FoundationUI.theme.padding(.regular).description)
        Text(FoundationUI.theme.padding(.large).description)
        Text(FoundationUI.theme.spacing(.regular).description)
        Text(FoundationUI.theme.spacing(.large).description)
    }
    .padding()
}
