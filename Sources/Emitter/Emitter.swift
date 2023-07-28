import UIKit
import Foundation
import QuartzCore

extension ThenMorphingLabel {
    
    // MARK: - Emitter
    struct Emitter {
        
        let layer: CAEmitterLayer = {
            let layer = CAEmitterLayer()
            // 粒子发射器的位置，这里设置为 (x: 10, y: 10)，表示在父视图的左上角
            layer.emitterPosition = CGPoint(x: 10, y: 10)
            // 粒子发射器的大小，这里设置为 (width: 10, height: 1)，表示宽度为 10，高度为 1
            layer.emitterSize = CGSize(width: 10, height: 1)
            // 粒子渲染模式，这里设置为 .unordered，表示粒子的位置和大小是随机的
            layer.renderMode = .unordered
            // 粒子发射器的形状
            layer.emitterShape = .line
            return layer
        }()
        
        let cell: CAEmitterCell = {
            let cell = CAEmitterCell()
            cell.name = "sparkle"
            cell.birthRate = 150.0
            cell.velocity = 50.0
            cell.velocityRange = -80.0
            cell.lifetime = 0.16
            cell.lifetimeRange = 0.1
            cell.emissionLongitude = CGFloat.pi / 2 * 2.0
            cell.emissionRange = CGFloat.pi / 2 * 2.0
            cell.scale = 0.1
            cell.yAcceleration = 100
            cell.scaleSpeed = -0.06
            cell.scaleRange = 0.1
            return cell
        }()
        
        public var duration: CGFloat = 0.6
        
        init(name: String, particleName: String, duration: CGFloat) {
            cell.name = name
            self.duration = duration
            var image: UIImage?
            defer {
                cell.contents = image?.cgImage
            }
            
            image = UIImage(named: particleName)
            if image == nil {
                // Load from Framework
                image = UIImage(
                    named: particleName,
                    in: Bundle(for: ThenMorphingLabel.self),
                    compatibleWith: nil)
            }
        }
        
        public func play() {
            // 如果动画正在播放，则返回
            if layer.emitterCells?.isEmpty == false {
                return
            }
            
            layer.emitterCells = [cell]
            let d = DispatchTime.now() + Double(Int64(duration * CGFloat(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: d) { [weak layer] in
                // 例子产生速率
                layer?.birthRate = 0.0
            }
        }
        
        public func stop() {
            if nil != layer.superlayer {
                layer.emitterCells = nil
                layer.removeFromSuperlayer()
            }
        }
        
        func update(_ configureClosure: EmitterConfigureClosure? = .none) -> Emitter {
            configureClosure?(layer, cell)
            return self
        }
        
    }
}
