import UIKit

extension ThenMorphingLabel {
    
    fileprivate func pixelateImageForCharacter(
        _ item: CharacterItem,
        withBlurRadius blurRadius: CGFloat
    ) -> UIImage {
        
        let scale = min(UIScreen.main.scale, 1.0 / blurRadius)
        UIGraphicsBeginImageContextWithOptions(item.rect.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        let fadeOutAlpha = min(
            1.0,
            max(
                0.0,
                item.drawingProgress * -2.0 + 2.0 + 0.01
            )
        )
        let rect = CGRect(
            x: 0,
            y: 0,
            width: item.rect.size.width,
            height: item.rect.size.height
        )
        String(item.char).draw(in: rect, withAttributes: [
            .font: self.font as Any,
            .foregroundColor: self.textColor.withAlphaComponent(fadeOutAlpha)
        ])
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext()
        else {
            return UIImage()
        }
        
        return newImage
    }
    
    @objc
    func PixelateLoad() {
        
        effectClosures[
            "\(Effect.pixelate.description)\(Phases.disappear)"
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
            "\(Effect.pixelate.description)\(Phases.appear)"
        ] = { char, index, progress in
            
            CharacterItem(
                char: char,
                rect: self.newRects[index],
                alpha: progress,
                size: self.font.pointSize,
                drawingProgress: 1.0 - progress
            )
        }
        
        drawingClosures[
            "\(Effect.pixelate.description)\(Phases.draw)"
        ] = { limbo in
            
            guard limbo.drawingProgress > 0.0 else {
                return false
            }
            let charImage = self.pixelateImageForCharacter(
                limbo,
                withBlurRadius: limbo.drawingProgress * 6.0
            )
            charImage.draw(in: limbo.rect)
            return true
        }
    }
    
}
