import UIKit

extension ThenMorphingLabel {
    
    @objc
    func EvaporateLoad() {
        
        progressClosures[
            "\(Effect.evaporate.description)\(Phases.progress)"
        ] = { (index: Int, _, isNewChar: Bool) in
            
            let j = Int(round(cos(Double(index)) * 1.2))
            let delay = isNewChar ? self.morphingCharacterDelay * -1.0 : self.morphingCharacterDelay
            return min(1.0, max(0.0, self.morphingProgress + delay * CGFloat(j)))
        }
        
        effectClosures[
            "\(Effect.evaporate.description)\(Phases.disappear)"
        ] = { char, index, progress in
            
            let newProgress = Easing.easeOutQuint(progress, 0.0, 1.0, 1.0)
            let yOffset = -0.8 * self.font.pointSize * newProgress
            let currentRect = self.previousRects[index].offsetBy(dx: 0, dy: yOffset)
            let currentAlpha = 1.0 - newProgress
            
            return CharacterItem(
                char: char,
                rect: currentRect,
                alpha: currentAlpha,
                size: self.font.pointSize,
                drawingProgress: 0.0)
        }
        
        effectClosures[
            "\(Effect.evaporate.description)\(Phases.appear)"
        ] = { char, index, progress in
            
            let newProgress = 1.0 - Easing.easeOutQuint(progress, 0.0, 1.0)
            let yOffset = self.font.pointSize * newProgress * 1.2
            
            return CharacterItem(
                char: char,
                rect: self.newRects[index].offsetBy(dx: 0, dy: yOffset),
                alpha: self.morphingProgress,
                size: self.font.pointSize,
                drawingProgress: 0.0
            )
        }
    }
    
}
