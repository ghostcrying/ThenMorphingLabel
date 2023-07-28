import UIKit

extension ThenMorphingLabel {
    
    @objc
    func AnvilLoad() {
        
        startClosures["\(Effect.anvil.description)\(Phases.start)"] = {
            self.emitterView.removeAllEmitters()
            
            guard self.newRects.count > 0 else { return }
            
            let centerRect = self.newRects[Int(self.newRects.count / 2)]
            
            // 向左飘动的烟雾
            self.emitterView.createEmitter(
                "leftSmoke",
                particleName: "Smoke",
                duration: 0.6
            ) { (layer, cell) in
                layer.emitterSize = CGSize(width: 1, height: 1)
                layer.emitterPosition = CGPoint(
                    x: centerRect.origin.x,
                    y: centerRect.origin.y + centerRect.size.height / 1.3)
                layer.renderMode = .unordered
                cell.emissionLongitude = CGFloat.pi / 2
                cell.scale = self.font.pointSize / 90.0
                cell.scaleSpeed = self.font.pointSize / 130
                cell.birthRate = 60
                cell.velocity = CGFloat(80 + Int(arc4random_uniform(60)))
                cell.velocityRange = 100
                cell.yAcceleration = -40
                cell.xAcceleration = 70
                cell.emissionLongitude = -CGFloat.pi / 2
                cell.emissionRange = CGFloat.pi / 4 / 5.0
                cell.lifetime = Float(self.morphingDuration) * 2.0
                cell.spin = 10
                cell.alphaSpeed = -0.5 / Float(self.morphingDuration)
            }
            
            // 向右飘动的烟雾
            self.emitterView.createEmitter(
                "rightSmoke",
                particleName: "Smoke",
                duration: 0.6
            ) { (layer, cell) in
                layer.emitterSize = CGSize(width: 1, height: 1)
                layer.emitterPosition = CGPoint(
                    x: centerRect.origin.x,
                    y: centerRect.origin.y + centerRect.size.height / 1.3)
                layer.renderMode = .unordered
                cell.emissionLongitude = CGFloat.pi / 2
                cell.scale = self.font.pointSize / 90.0
                cell.scaleSpeed = self.font.pointSize / 130
                cell.birthRate = 60
                cell.velocity = CGFloat(80 + Int(arc4random_uniform(60)))
                cell.velocityRange = 100
                cell.yAcceleration = -40
                cell.xAcceleration = -70
                cell.emissionLongitude = CGFloat.pi / 2
                cell.emissionRange = -CGFloat.pi / 4 / 5.0
                cell.lifetime = Float(self.morphingDuration) * 2.0
                cell.spin = -10
                cell.alphaSpeed = -0.5 / Float(self.morphingDuration)
            }
            // 向左飘动的碎片
            self.emitterView.createEmitter(
                "leftFragments",
                particleName: "Fragment",
                duration: 0.6
            ) { (layer, cell) in
                layer.emitterSize = CGSize(
                    width: self.font.pointSize,
                    height: 1
                )
                layer.emitterPosition = CGPoint(
                    x: centerRect.origin.x,
                    y: centerRect.origin.y + centerRect.size.height / 1.3
                )
                cell.scale = self.font.pointSize / 90.0
                cell.scaleSpeed = self.font.pointSize / 40.0
                cell.color = self.textColor.cgColor
                cell.birthRate = 60
                cell.velocity = 350
                cell.yAcceleration = 0
                cell.xAcceleration = CGFloat(10 * Int(arc4random_uniform(10)))
                cell.emissionLongitude = -CGFloat.pi / 2
                cell.emissionRange = CGFloat.pi / 4 / 5.0
                cell.alphaSpeed = -2
                cell.lifetime = Float(self.morphingDuration)
            }
            
            self.emitterView.createEmitter(
                "rightFragments",
                particleName: "Fragment",
                duration: 0.6
            ) { (layer, cell) in
                layer.emitterSize = CGSize(
                    width: self.font.pointSize,
                    height: 1
                )
                layer.emitterPosition = CGPoint(
                    x: centerRect.origin.x,
                    y: centerRect.origin.y + centerRect.size.height / 1.3)
                cell.scale = self.font.pointSize / 90.0
                cell.scaleSpeed = self.font.pointSize / 40.0
                cell.color = self.textColor.cgColor
                cell.birthRate = 60
                cell.velocity = 350
                cell.yAcceleration = 0
                cell.xAcceleration = CGFloat(-10 * Int(arc4random_uniform(10)))
                cell.emissionLongitude = CGFloat.pi / 2
                cell.emissionRange = -CGFloat.pi / 4 / 5.0
                cell.alphaSpeed = -2
                cell.lifetime = Float(self.morphingDuration)
            }
            
            // 向上飘动的碎片
            self.emitterView.createEmitter(
                "fragments",
                particleName: "Fragment",
                duration: 0.6
            ) { (layer, cell) in
                layer.emitterSize = CGSize(
                    width: self.font.pointSize,
                    height: 1
                )
                layer.emitterPosition = CGPoint(
                    x: centerRect.origin.x,
                    y: centerRect.origin.y + centerRect.size.height / 1.3
                )
                cell.scale = self.font.pointSize / 90.0
                cell.scaleSpeed = self.font.pointSize / 40.0
                cell.color = self.textColor.cgColor
                cell.birthRate = 60
                cell.velocity = 250
                cell.velocityRange = CGFloat(Int(arc4random_uniform(20)) + 30)
                cell.yAcceleration = 500
                cell.emissionLongitude = 0
                cell.emissionRange = CGFloat.pi / 2
                cell.alphaSpeed = -1
                cell.lifetime = Float(self.morphingDuration)
            }
        }
        
        progressClosures[
            "\(Effect.anvil.description)\(Phases.progress)"
        ] = { (index: Int, progress: CGFloat, isNewChar: Bool) in
            
            guard isNewChar else {
                return min(1.0, max(0.0, progress))
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
            "\(Effect.anvil.description)\(Phases.disappear)"
        ] = { char, index, progress in
            
            CharacterItem(
                char: char,
                rect: self.previousRects[index],
                alpha: 1.0 - progress,
                size: self.font.pointSize,
                drawingProgress: 0.0
            )
        }
        
        effectClosures[
            "\(Effect.anvil.description)\(Phases.appear)"
        ] = { char, index, progress in
            
            var rect = self.newRects[index]
            if progress < 1.0 {
                let easingValue = Easing.easeOutBounce(progress, 0.0, 1.0)
                rect.origin.y = rect.origin.y * easingValue
            }
            
            if progress > self.morphingDuration * 0.5 {
                let end = self.morphingDuration * 0.55
                self.emitterView.createEmitter(
                    "fragments",
                    particleName: "Fragment",
                    duration: 0.6
                ) { (_, _) in }.update { (layer, _) in
                    if progress > end {
                        layer.birthRate = 0
                    }
                }.play()
                
                self.emitterView.createEmitter(
                    "leftFragments",
                    particleName: "Fragment",
                    duration: 0.6
                ) { (_, _) in }.update {  (layer, _) in
                    if progress > end {
                        layer.birthRate = 0
                    }
                }.play()
                
                self.emitterView.createEmitter(
                    "rightFragments",
                    particleName: "Fragment",
                    duration: 0.6
                ) { (_, _) in }.update { (layer, _) in
                    if progress > end {
                        layer.birthRate = 0
                    }
                }.play()
            }
            
            if progress > self.morphingDuration * 0.63 {
                let end = self.morphingDuration * 0.7
                self.emitterView.createEmitter(
                    "leftSmoke",
                    particleName: "Smoke",
                    duration: 0.6
                ) { (_, _) in }.update { (layer, _) in
                    if progress > end {
                        layer.birthRate = 0
                    }
                }.play()
                
                self.emitterView.createEmitter(
                    "rightSmoke",
                    particleName: "Smoke",
                    duration: 0.6
                ) { (_, _) in }.update { (layer, _) in
                    if progress > end {
                        layer.birthRate = 0
                    }
                }
                .play()
            }
            
            return CharacterItem(
                char: char,
                rect: rect,
                alpha: self.morphingProgress,
                size: self.font.pointSize,
                drawingProgress: CGFloat(progress                                        )
            )
        }
    }
    
}

