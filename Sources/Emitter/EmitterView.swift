import UIKit
import Foundation

/// CAEmitterCell: 用于创建例子效果动画
typealias EmitterConfigureClosure = (CAEmitterLayer, CAEmitterCell) -> ()

// MARK: - EmitterView
extension ThenMorphingLabel {
    
    class EmitterView: UIView {
        // 保存多个粒子效果动画
        lazy var emitters: [String: Emitter] = {
            var _emitters = [String: Emitter]()
            return _emitters
        }()
        
        @discardableResult
        func createEmitter(
            _ name: String,
            particleName: String,
            duration: CGFloat,
            configureClosure: EmitterConfigureClosure?
        ) -> Emitter {
            if let e = emitters[name] {
                return e
            }
            let emitter = Emitter(
                name: name,
                particleName: particleName,
                duration: duration
            )
            configureClosure?(emitter.layer, emitter.cell)
            
            layer.addSublayer(emitter.layer)
            emitters.updateValue(emitter, forKey: name)
            return emitter
        }
        
        func removeAllEmitters() {
            emitters.forEach {
                $0.value.layer.removeFromSuperlayer()
            }
            emitters.removeAll(keepingCapacity: false)
        }
        
    }
}
