//
//  ColorScale.swift
//
//
//  Created by Art Lasovsky on 20/12/2023.
//

import Foundation
import SwiftUI

// MARK: - Tint & Color

public extension FoundationUI {
    struct Tint: Sendable {
        public let light: SwiftUI.Color
        public let lightAccessible: SwiftUI.Color?
        public let dark: SwiftUI.Color
        public let darkAccessible: SwiftUI.Color?
        
        public init(light: SwiftUI.Color, lightAccessible: SwiftUI.Color? = nil, dark: SwiftUI.Color, darkAccessible: SwiftUI.Color? = nil) {
            self.light = light
            self.lightAccessible = lightAccessible
            self.dark = dark
            self.darkAccessible = darkAccessible
        }
        
        public init(_ universal: SwiftUI.Color, accessible: SwiftUI.Color? = nil) {
            self.light = universal
            self.lightAccessible = accessible
            self.dark = universal
            self.darkAccessible = accessible
        }
    }
    struct ColorScale: ShapeStyle {
        public struct Adjust: Sendable {
            typealias Closure = @Sendable (_ source: Components) -> Components
            let light: Closure?
            let lightAccessible: Closure?
            let dark: Closure?
            let darkAccessible: Closure?
            init(light: Closure?, lightAccessible: Closure? = nil, dark: Closure?, darkAccessible: Closure? = nil) {
                self.light = light
                self.lightAccessible = lightAccessible
                self.dark = dark
                self.darkAccessible = darkAccessible
            }
        }
        public var adjust: Adjust?
        
        // TODO:
        // vibrant variant – plusBlend
        // transparent variant (here or in the theme?)
        
        // Overrides
        struct Overrides {
            struct OpacityOverride {
                let light: CGFloat
                let dark: CGFloat
                
                init(light: CGFloat, dark: CGFloat? = nil) {
                    self.light = light
                    self.dark = dark ?? light
                }
            }
            var tint: FoundationUI.Tint?
            var opacity: OpacityOverride?
            var colorScheme: ColorScheme?
        }
        private var overrides = Overrides()
        
        private var blendMode: BlendMode?
        
        init(light: Adjust.Closure? = nil, lightAccessible: Adjust.Closure? = nil, dark: Adjust.Closure? = nil, darkAccessible: Adjust.Closure? = nil) {
            self.adjust = .init(
                light: light,
                lightAccessible: lightAccessible,
                dark: dark,
                darkAccessible: darkAccessible)
        }
        
        public init(light: ColorScale, lightAccessible: ColorScale? = nil, dark: ColorScale, darkAccessible: ColorScale? = nil) {
            self.adjust = .init(
                light: light.adjust?.light,
                dark: dark.adjust?.dark
            )
            
            self.overrides.opacity = .init(
                light: light.overrides.opacity?.light ?? self.overrides.opacity?.light ?? 1,
                dark: dark.overrides.opacity?.dark ?? self.overrides.opacity?.dark ?? 1)
        }
        
        public func tint(_ tint: FoundationUI.Tint) -> Self {
            var copy = self
            copy.overrides.tint = tint
            return copy
        }
        
        public func tint(color: Color) -> Self {
            var copy = self
            copy.overrides.tint = .init(color)
            return copy
        }
        
        public func opacity(_ value: CGFloat) -> Self {
            var copy = self
            copy.overrides.opacity = .init(light: value)
            return copy
        }
        
        public func blendMode(_ value: BlendMode) -> Self {
            var copy = self
            copy.blendMode = value
            return copy
        }
        
        public func colorScheme(_ colorScheme: ColorScheme) -> Self {
            var copy = self
            copy.overrides.colorScheme = colorScheme
            return copy
        }
        
        public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
            var color: any ShapeStyle = resolveColor(in: environment)
            if let blendMode {
                color = color.blendMode(blendMode)
            }
            return AnyShapeStyle(color)
        }
        
        internal func resolveComponents(in environment: EnvironmentValues) -> Components? {
            getComponents(color: resolveColor(in: environment))
        }
        
        public func resolveColor(in environment: EnvironmentValues) -> Color {
            let tint = overrides.tint ?? environment.foundationUITint
            let adjustLight = adjust?.light
            let adjustLightAccessible = adjust?.lightAccessible ?? adjust?.light
            let adjustDark = adjust?.dark
            let adjustDarkAccessible = adjust?.darkAccessible ?? adjust?.dark
            
            let colorScheme = overrides.colorScheme ?? environment.colorScheme
            
            let lightColorScheme = colorScheme == .light
            let accessibility = (
                contrast: environment.colorSchemeContrast == .increased,
                invertColors: environment.accessibilityInvertColors,
                reduceTransparency: environment.accessibilityReduceTransparency,
                differentiateWithoutColor: environment.accessibilityDifferentiateWithoutColor
            )
            
            var color: Color
            if accessibility.contrast {
                color = lightColorScheme ? tint.lightAccessible ?? tint.light : tint.darkAccessible ?? tint.dark
            } else {
                color = lightColorScheme ? tint.light : tint.dark
            }
            

            guard let components = getComponents(color: color) else {
                print("cannot get components")
                return SwiftUI.Color.red
            }
            
            // TODO: Simplify logic here, do not repeat
            if lightColorScheme {
                color = (accessibility.contrast
                         ? adjustLightAccessible?(components).color()
                         : adjustLight?(components).color()) ?? color
            } else {
                color = (accessibility.contrast
                         ? adjustDarkAccessible?(components).color()
                         : adjustDark?(components).color()) ?? color
            }
            
            if let opacityOverride = overrides.opacity {
                color = color.opacity(lightColorScheme ? opacityOverride.light : opacityOverride.dark)
            }
            
            return color
        }
    }
}

// MARK: - Color Scale

extension FoundationUI.ColorScale {
    private func getComponents(color: SwiftUI.Color?) -> Components? {
        #if os(iOS)
        guard let color else { return nil }
        var hue: CGFloat = 0,
            saturation: CGFloat = 0,
            brightness: CGFloat = 0,
            alpha: CGFloat = 0
        UIColor(color).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let components = (hueComponent: hue, saturationComponent: saturation, brightnessComponent: brightness, alphaComponent: alpha)
        #endif
        #if os(macOS)
        guard let color, let components = NSColor(color).usingColorSpace(.deviceRGB) else { return nil }
        #endif
        return .init(components.hueComponent, components.saturationComponent, components.brightnessComponent, components.alphaComponent)
    }
    struct Components: Sendable {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
        let alpha: CGFloat
        
        init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
            self.hue = Self.clamp(hue)
            self.saturation = Self.clamp(saturation)
            self.brightness = Self.clamp(brightness)
            self.alpha = Self.clamp(alpha)
        }
        
        init(_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat, _ alpha: CGFloat = 1) {
            self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        private static func clamp(_ value: CGFloat) -> CGFloat {
            max(0, min(1, value))
        }
        
        func multiply(hue: CGFloat = 1, saturation: CGFloat = 1, brightness: CGFloat = 1, alpha: CGFloat = 1) -> Self {
            .init(self.hue * hue, self.saturation * saturation, self.brightness * brightness, self.alpha * alpha)
        }
        
        func set(hue: CGFloat? = nil, saturation: CGFloat? = nil, brightness: CGFloat? = nil, alpha: CGFloat? = nil) -> Self {
            .init(hue ?? self.hue, saturation ?? self.saturation, brightness ?? self.brightness, alpha ?? self.alpha)
        }
        
        var isSaturated: Bool {
            saturation > 0
        }
        
        func shapeStyle() -> some ShapeStyle {
            SwiftUI.Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
        }
        
        func color() -> SwiftUI.Color {
            SwiftUI.Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
        }
    }
}

// MARK: EnvironmentValues

private struct FoundationUITintKey: EnvironmentKey {
    static let defaultValue: FoundationUI.Tint = .init(
        light: .init(hue: 0, saturation: 0, brightness: 0.43),
        dark: .init(hue: 0, saturation: 0, brightness: 0.55)
    )
}
private struct FoundationUICornerRadiusKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}
extension EnvironmentValues {
    var foundationUITint: FoundationUI.Tint {
        get { self[FoundationUITintKey.self] }
        set { self[FoundationUITintKey.self] = newValue }
    }
    var foundationUICornerRadius: CGFloat? {
        get { self[FoundationUICornerRadiusKey.self] }
        set { self[FoundationUICornerRadiusKey.self] = newValue }
    }
}
