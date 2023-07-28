import UIKit

extension ThenMorphingLabel {
    
    fileprivate func maskedImageForCharacter(
        _ item: CharacterItem,
        withProgress progress: CGFloat
    ) -> (UIImage, CGRect) {
        let maskedHeight = item.rect.size.height * max(0.01, progress)
        let maskedSize = CGSize(
            width: item.rect.size.width,
            height: maskedHeight
        )
        UIGraphicsBeginImageContextWithOptions(
            maskedSize,
            false,
            UIScreen.main.scale
        )
        defer { UIGraphicsEndImageContext() }
        let rect = CGRect(
            x: 0,
            y: 0,
            width: item.rect.size.width,
            height: maskedHeight
        )
        String(item.char).draw(in: rect, withAttributes: [
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any
        ])
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return (UIImage(), CGRect.zero)
        }
        let newRect = CGRect(
            x: item.rect.origin.x,
            y: item.rect.origin.y,
            width: item.rect.size.width,
            height: maskedHeight
        )
        return (newImage, newRect)
    }
    
    @objc
    func SparkleLoad() {
        
        startClosures[
            "\(Effect.sparkle.description)\(Phases.start)"
        ] = {
            self.emitterView.removeAllEmitters()
        }
        
        progressClosures[
            "\(Effect.sparkle.description)\(Phases.progress)"
        ] = { (index: Int, progress: CGFloat, isNewChar: Bool) in
            
            guard isNewChar else {
                return min(1.0, max(0.0, progress))
            }
            let j = sin(CGFloat(index)) * 1.5
            return min(
                1.0,
                max(
                    0.0001,
                    progress + self.morphingCharacterDelay * j
                )
            )
            
        }
        
        effectClosures[
            "\(Effect.sparkle.description)\(Phases.disappear)"
        ] = { char, index, progress in
            
            CharacterItem(
                char: char,
                rect: self.previousRects[index],
                alpha: 1.0 - progress,
                size: self.font.pointSize,
                drawingProgress: 0.0)
        }
        
        effectClosures[
            "\(Effect.sparkle.description)\(Phases.appear)"
        ] = { char, index, progress in
            
            if char != " " {
                let rect = self.newRects[index]
                let emitterPosition = CGPoint(
                    x: rect.origin.x + rect.size.width / 2.0,
                    y: progress * rect.size.height * 0.9 + rect.origin.y
                )
                
                self.emitterView.createEmitter(
                    "c\(index)",
                    particleName: "Sparkle",
                    duration: self.morphingDuration
                ) { (layer, cell) in
                    layer.emitterSize = CGSize(
                        width: rect.size.width,
                        height: 1
                    )
                    layer.renderMode = .unordered
                    cell.emissionLongitude = CGFloat(Double.pi / 2.0)
                    cell.scale = self.font.pointSize / 300.0
                    cell.scaleSpeed = self.font.pointSize / 300.0 * -1.5
                    cell.color = self.textColor.cgColor
                    cell.birthRate = Float(self.font.pointSize) * Float(arc4random_uniform(7) + 3)
                }.update { (layer, _) in
                    layer.emitterPosition = emitterPosition
                }.play()
            }
            
            return CharacterItem(
                char: char,
                rect: self.newRects[index],
                alpha: self.morphingProgress,
                size: self.font.pointSize,
                drawingProgress: CGFloat(progress)
            )
        }
        
        drawingClosures[
            "\(Effect.sparkle.description)\(Phases.draw)"
        ] = { (charLimbo: CharacterItem) in
            
            guard charLimbo.drawingProgress > 0.0 else {
                return false
            }
            let (charImage, rect) = self.maskedImageForCharacter(
                charLimbo,
                withProgress: charLimbo.drawingProgress
            )
            charImage.draw(in: rect)
            return true
        }
        
        skipFramesClosures["Sparkle\(Phases.skipFrames)"] = {
            return 1
        }
    }
    
}
