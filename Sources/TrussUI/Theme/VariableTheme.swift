//
//  VariableTheme.swift
//  
//
//  Created by Art Lasovsky on 18/01/2024.
//

import Foundation
import SwiftUI

// MARK: - Extensions
public extension CGFloat {
    typealias truss = TrussUI.Variable.Theme<Self>
}

public extension Font {
    typealias truss = TrussUI.Variable.Theme<Self>
}

public extension Animation {
    typealias truss = TrussUI.Variable.Theme<Self>
}

// MARK: - Variable Theme
public extension TrussUI.Variable {
    struct Theme<V>: VariableTheme {
        public typealias Value = V
        private init() {}
    }
}

public protocol VariableTheme {
    associatedtype Value
}

// MARK: - Variable Theme Extensions
public extension VariableTheme where Value == ShadowConfiguration {
    static func shadow(_ variable: TrussUI.Variable.Shadow) -> Value {
        variable.value
    }
}

public extension VariableTheme where Value == Font {
    static func font(_ variable: TrussUI.Variable.Font) -> Value {
        variable.value
    }
}

public extension VariableTheme where Value == Animation {
    static func animation(_ variable: TrussUI.Variable.Animation) -> Value {
        variable.value
    }
}

public extension VariableTheme where Value == CGFloat {
    static func padding(_ variable: TrussUI.Variable.Padding) -> Value {
        variable.value
    }
    static func spacing(_ variable: TrussUI.Variable.Spacing) -> Value {
        variable.value
    }
    static func size(_ variable: TrussUI.Variable.Size) -> Value {
        variable.value
    }
    static func radius(_ variable: TrussUI.Variable.Radius) -> Value {
        variable.value
    }
}

// MARK: - Variable
extension TrussUI {
    public enum Variable {
        public struct Padding: VariableScale {
            public var value: CGFloat
            public var label: String?
            public init(value: CGFloat, label: String? = nil) {
                self.value = value
                self.label = label
            }
            
            public static var regular = Self("regular", 8)
        }
        public struct Spacing: VariableScale {
            public var value: CGFloat
            public var label: String?
            public init(value: CGFloat, label: String? = nil) {
                self.value = value
                self.label = label
            }
            
            public static var regular = Self("regular", .truss.padding(.regular) * 0.5)
        }
        public struct Size: VariableScale {
            public var value: CGFloat
            public var label: String?
            public init(value: CGFloat, label: String? = nil) {
                self.value = value
                self.label = label
            }
            
            public static var regular = Self("regular", .truss.padding(.regular) * 8)
        }
        public struct Radius: VariableScale {
            public var value: CGFloat
            public var label: String?
            public init(value: CGFloat, label: String? = nil) {
                self.value = value
                self.label = label
            }
            
            public static let regular = Self("regular", 8)
        }
        public struct Font: VariableScale {
            public var value: SwiftUI.Font
            public var label: String?
            public init(value: SwiftUI.Font, label: String?) {
                self.value = value
                self.label = label
            }
            
            public static let xxSmall = Self("xxSmall", .footnote)
            public static let xSmall = Self("xSmall", .subheadline)
            public static let small = Self("small", .callout)
            public static let regular = Self("regular", .body)
            public static let large = Self("large", .title3)
            public static let xLarge = Self("xLarge", .title2)
            public static let xxLarge = Self("xxLarge", .title)
        }
        
        public struct Animation: VariableValue {
            public var value: SwiftUI.Animation
            public var label: String?
            public init(value: SwiftUI.Animation, label: String?) {
                self.value = value
                self.label = label
            }
            
            public static let `regular` = Self("regular", .interactiveSpring())
        }
        
        public struct Shadow: VariableScale {
            public var value: ShadowConfiguration
            public var label: String?
            public init(value: ShadowConfiguration, label: String?) {
                self.value = value
                self.label = label
            }
            private static let colorVariable: TrussUI.TintedColorSet = .background.colorScheme(.dark).tint(.primary)
            public static var xxSmall = Self("xxSmall", .init(radius: 0.5, colorVariable: colorVariable.opacity(0.1), x: 0, y: 0.5))
            public static var xSmall = Self("xSmall", .init(radius: 1, colorVariable: colorVariable.opacity(0.15), x: 0, y: 1))
            public static var small = Self("small", .init(radius: 1.5, colorVariable: colorVariable.opacity(0.2), x: 0, y: 1))
            public static var regular = Self("regular", .init(radius: 2.5, colorVariable: colorVariable.opacity(0.25), x: 0, y: 1))
            public static var large = Self("large", .init(radius: 3.5, colorVariable: colorVariable.opacity(0.3), x: 0, y: 1))
            public static var xLarge = Self("xLarge", .init(radius: 4, colorVariable: colorVariable.opacity(0.4), x: 0, y: 1))
            public static var xxLarge = Self("xxLarge", .init(radius: 12, colorVariable: colorVariable.opacity(0.6), x: 0, y: 1))
        }
    }
}


// MARK: Swatch
public extension VariableValue {
    @ViewBuilder
    static func swatch(for variables: [Self], content: @escaping (Self) -> some View) -> some View {
        VariableScaleSwatch(variables: variables, content: content)
    }
}

public extension VariableScale where Value == CGFloat {
    @ViewBuilder
    static func swatch(for variables: [Self]) -> some View {
        swatch(for: variables) { Text($0.value.description) }
    }
}

public extension TrussUI.Variable.Font {
    @ViewBuilder
    static func swatch(for variables: [Self]) -> some View {
        swatch(for: variables, content: { Text("Abc").font($0.value) })
    }
}

private struct VariableScaleSwatch<Variable: VariableValue, Content: View>: View {
    let variables: [Variable]
    @ViewBuilder var content: (Variable) -> Content
    var label: String {
        Mirror(reflecting: Variable.Type.self).description
            .replacingOccurrences(of: "Mirror for ", with: "")
            .replacingOccurrences(of: ".Type", with: "")
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            ForEach(variables, id: \.self) { variable in
                HStack(alignment: .bottom) {
                    Text(variable.label ?? "-")
                        .opacity(0.5)
                        .font(.caption.monospaced())
                    Spacer()
                    content(variable)
                }
            }
            .frame(width: 120)
        }
    }
}

// MARK: CGFloat Variable Scale
public extension VariableScale where Value == CGFloat {
    /// Negative value
    func negative() -> Self {
        .init(self.value * -1)
    }
    
    func offset(_ offset: Value, label: String? = nil) -> Self {
        let value = Self(label, value + value * offset * (offset < 0 ? 0.5 : 1))
        return value
    }
    
    func offset(_ offset: VariableScaleOffset, label: String? = nil) -> Self {
        self.offset(offset.rawValue, label: label)
    }
    
    static var xxSmall: Self { xSmall.offset(-1, label: "xxSmall") }
    static var xSmall: Self { small.offset(-1, label: "xSmall") }
    static var small: Self { regular.offset(-1, label: "small") }
    static var large: Self { regular.offset(1, label: "large") }
    static var xLarge: Self { large.offset(1, label: "xLarge") }
    static var xxLarge: Self { xLarge.offset(1, label: "xxLarge") }
}

public struct VariableScaleOffset: RawRepresentable {
    public var rawValue: CGFloat
    public init(rawValue: CGFloat) {
        self.rawValue = rawValue
    }
    public static let full = Self(rawValue: 1)
    public static let half = Self(rawValue: 0.5)
    public static let third = Self(rawValue: 1 / 3)
    public static let quarter = Self(rawValue: 1 / 4)
    
    public var up: Self {
        self
    }
    public var down: Self {
        .init(rawValue: self.rawValue * -1)
    }
}

// TODO: Previews for all theme values
struct VariablePreview: PreviewProvider {
    // All values should be accessible without explicit type
    static let test = TrussUI.Variable.Theme.animation(.regular)
    static let padding: CGFloat = .truss.padding(.regular)
    static var previews: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle().frame(width: .truss.size(.regular),
                              height: TrussUI.Variable.Theme.size(.small))
            Text(TrussUI.Variable.Theme.padding(.small).description)
            TrussUI.Variable.Padding.swatch(for: [
                .xxSmall,
                .xSmall,
                .small,
                .regular,
                .large,
                .xLarge,
                .xxLarge
            ])
            TrussUI.Variable.Spacing.swatch(for: [
                .xxSmall,
                .xSmall,
                .small,
                .regular,
                .large,
                .xLarge,
                .xxLarge
            ])
            TrussUI.Variable.Font.swatch(for: [
                .xxSmall,
                .xSmall,
                .small,
                .regular,
                .large,
                .xLarge,
                .xxLarge
            ])
        }
        .padding()
    }
}
