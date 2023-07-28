import UIKit

extension ThenMorphingLabel {
    
    @objc
    func FallLoad() {
        
        progressClosures[
            "\(Effect.fall.description)\(Phases.progress)"
        ] = { (index: Int, progress: CGFloat, isNewChar: Bool) in
            
            if isNewChar {
                return min(
                    1.0,
                    max(0.0,
                        progress
                        - self.morphingCharacterDelay
                        * CGFloat(index)
                        / 1.7
                       )
                )
            }
            
            let j = sin(CGFloat(index)) * 1.7
            return min(
                1.0,
                max(
                    0.0001,
                    progress + self.morphingCharacterDelay * j
                )
            )
        }
        
        effectClosures[
            "\(Effect.fall.description)\(Phases.disappear)"
        ] = { char, index, progress in
            
            CharacterItem(
                char: char,
                rect: self.previousRects[index],
                alpha: 1.0 - progress,
                size: self.font.pointSize,
                drawingProgress: progress
            )
        }
        
        effectClosures[
            "\(Effect.fall.description)\(Phases.appear)"
        ] = { char, index, progress in
            
            let currentFontSize = Easing.easeOutQuint(progress, 0.0, self.font.pointSize)
            let yOffset = self.font.pointSize - currentFontSize
            
            return CharacterItem(
                char: char,
                rect: self.newRects[index].offsetBy(dx: 0, dy: yOffset),
                alpha: self.morphingProgress,
                size: currentFontSize,
                drawingProgress: 0.0
            )
        }
        
        drawingClosures[
            "\(Effect.fall.description)\(Phases.draw)"
        ] = { limbo in
            guard limbo.drawingProgress > 0.0, let context = UIGraphicsGetCurrentContext() else {
                return false
            }
            var charRect = limbo.rect
            context.saveGState()
            let charCenterX = charRect.origin.x + (charRect.size.width / 2.0)
            var charBottomY = charRect.origin.y + charRect.size.height - self.font.pointSize / 6
            var charColor: UIColor = self.textColor
            
            // Fall down if drawingProgress is more than 50%
            if limbo.drawingProgress > 0.5 {
                let ease = Easing.easeInQuint(
                    limbo.drawingProgress - 0.4,
                    0.0,
                    1.0,
                    0.5)
                charBottomY += ease * 10.0
                let fadeOutAlpha = min(
                    1.0,
                    max(
                        0.0,
                        limbo.drawingProgress * -2.0 + 2.0 + 0.01
                    )
                )
                charColor = self.textColor.withAlphaComponent(fadeOutAlpha)
            }
            
            charRect = CGRect(
                x: charRect.size.width / -2.0,
                y: charRect.size.height * -1.0 + self.font.pointSize / 6,
                width: charRect.size.width,
                height: charRect.size.height
            )
            context.translateBy(x: charCenterX, y: charBottomY)
            
            let angle = CGFloat(sin(limbo.rect.origin.x) > 0.5 ? 168 : -168)
            let rotation = Easing.easeOutBack(
                min(1.0, limbo.drawingProgress),
                0.0,
                1.0
            ) * angle
            
            context.rotate(by: rotation * CGFloat.pi / 180.0)
            let s = String(limbo.char)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: self.font.withSize(limbo.size),
                .foregroundColor: charColor
            ]
            s.draw(in: charRect, withAttributes: attributes)
            context.restoreGState()
            return true
        }
    }
    
}
