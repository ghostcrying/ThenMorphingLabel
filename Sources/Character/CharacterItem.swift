import Foundation

extension ThenMorphingLabel {
    
    struct CharacterItem: CustomDebugStringConvertible {
        
        let char:  Character
        var rect:  CGRect
        var alpha: CGFloat
        var size:  CGFloat
        var drawingProgress: CGFloat = 0.0
        
        var debugDescription: String {
            return "Character: '\(char)'"
                    + "drawIn (\(rect.origin.x), \(rect.origin.y), "
                    + "\(rect.size.width)x\(rect.size.height) "
                    + "with alpha \(alpha) "
                    + "and \(size)pt font."
        }
        
    }
    
}
