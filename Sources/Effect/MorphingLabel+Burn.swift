import UIKit

extension ThenMorphingLabel {
    
    fileprivate func burningImageForCharacter(
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
            return (UIImage() , .zero)
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
    func BurnLoad() {
        
        startClosures["\(Effect.burn.description)\(Phases.start)"] = {
            self.emitterView.removeAllEmitters()
        }
        
        progressClosures[
            "\(Effect.burn.description)\(Phases.progress)"
        ] = { index, progress, isNewChar in
            
            guard isNewChar else {
                return min(1.0, max(0.0, progress))
            }
            
            let j = sin(CGFloat(index)) * 1.5
            return min(1.0, max(0.0001, progress + self.morphingCharacterDelay * j))
        }
        
        effectClosures[
            "\(Effect.burn.description)\(Phases.disappear)"]
        = { char, index, progress in
            
            CharacterItem(
                char: char,
                rect: self.previousRects[index],
                alpha: 1.0 - progress,
                size: self.font.pointSize,
                drawingProgress: 0.0
            )
        }
        
        effectClosures[
            "\(Effect.burn.description)\(Phases.appear)"
        ] = { char, index, progress in
            
            if char != " " {
                let rect = self.newRects[index]
                let emitterPosition = CGPoint(
                    x: rect.origin.x + rect.size.width / 2.0,
                    y: CGFloat(progress) * rect.size.height / 1.2 + rect.origin.y
                )
                
                self.emitterView.createEmitter(
                    "c\(index)",
                    particleName: "Fire",
                    duration: self.morphingDuration
                ) { (layer, cell) in
                    layer.emitterSize = CGSize(
                        width: rect.size.width,
                        height: 1
                    )
                    layer.renderMode = CAEmitterLayerRenderMode.additive
                    layer.emitterMode = CAEmitterLayerEmitterMode.outline
                    cell.emissionLongitude = CGFloat.pi / 2
                    cell.scale = self.font.pointSize / 160.0
                    cell.scaleSpeed = self.font.pointSize / 100.0
                    cell.birthRate = Float(self.font.pointSize)
                    cell.emissionLongitude = CGFloat(arc4random_uniform(30))
                    cell.emissionRange = CGFloat.pi / 4
                    cell.alphaSpeed = Float(self.morphingDuration) * -3.0
                    cell.yAcceleration = 10
                    cell.velocity = CGFloat(10 + Int(arc4random_uniform(3)))
                    cell.velocityRange = 10
                    cell.spin = 0
                    cell.spinRange = 0
                    cell.lifetime = Float(self.morphingDuration) / 3.0
                }.update { (layer, _) in
                    layer.emitterPosition = emitterPosition
                }.play()
                
                self.emitterView.createEmitter(
                    "s\(index)",
                    particleName: "Smoke",
                    duration: self.morphingDuration
                ) { (layer, cell) in
                    layer.emitterSize = CGSize(
                        width: rect.size.width,
                        height: 10
                    )
                    layer.renderMode = CAEmitterLayerRenderMode.additive
                    layer.emitterMode = CAEmitterLayerEmitterMode.volume
                    cell.emissionLongitude = CGFloat(Double.pi / 2)
                    cell.scale = self.font.pointSize / 40.0
                    cell.scaleSpeed = self.font.pointSize / 100.0
                    cell.birthRate = Float(self.font.pointSize) / Float(arc4random_uniform(10) + 10)
                    cell.emissionLongitude = 0
                    cell.emissionRange = CGFloat.pi / 4
                    cell.alphaSpeed = Float(self.morphingDuration) * -3
                    cell.yAcceleration = -5
                    cell.velocity = CGFloat(20 + Int(arc4random_uniform(15)))
                    cell.velocityRange = 20
                    cell.spin = CGFloat(Float(arc4random_uniform(30)) / 10.0)
                    cell.spinRange = 3
                    cell.lifetime = Float(self.morphingDuration)
                }.update { (layer, _) in
                    layer.emitterPosition = emitterPosition
                }.play()
            }
            
            return CharacterItem(
                char: char,
                rect: self.newRects[index],
                alpha: 1.0,
                size: self.font.pointSize,
                drawingProgress: progress
            )
        }
        
        drawingClosures[
            "\(Effect.burn.description)\(Phases.draw)"
        ] = { item in
            
            guard item.drawingProgress > 0.0 else {
                return false
            }
            let (charImage, rect) = self.burningImageForCharacter(
                item,
                withProgress: item.drawingProgress
            )
            charImage.draw(in: rect)
            return true
        }
        
        skipFramesClosures["\(Effect.burn.description)\(Phases.skipFrames)"] = {
            return 1
        }
    }
    
}
