//
//  MorphingText.swift
//  ThenMorphingLabel
//
//  Created by 陈卓 on 2023/7/28.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0.0, *)
public struct MorphingText: UIViewRepresentable {
    
    public typealias UIViewType = ThenMorphingLabel
    
    var text: String
    var morphingEffect: ThenMorphingLabel.Effect
    var moprhingEnabled: Bool = true
    var font: UIFont
    var textColor: UIColor
    var textAlignment: NSTextAlignment
    
    public init(_ text: String,
                effect: ThenMorphingLabel.Effect = .scale,
                font: UIFont = .systemFont(ofSize: 16),
                textColor: UIColor = .black,
                textAlignment: NSTextAlignment = .center
    ) {
        self.text = text
        self.morphingEffect = effect
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let label = ThenMorphingLabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 50)))
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.morphingEffect = morphingEffect
        uiView.morphingEnabled = moprhingEnabled
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
    }
}
