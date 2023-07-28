import Foundation
import CoreGraphics

extension ThenMorphingLabel {
    
    // http://gsgd.co.uk/sandbox/jquery/easing/jquery.easing.1.3.js
    // t = currentTime
    // b = beginning
    // c = change
    // d = duration
    
    /// 以便创建具有平滑、自然和逼真动画效果的动画序列
    struct Easing {
        
        /// 缓动函数，以匀速的方式结束动画
        public static func linear(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat = 1.0) -> CGFloat {
            return c * (t / d) + b
        }
        
        /// 五次方缓动函数，以慢慢减速的方式结束动画
        public static func easeOutQuint(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat = 1.0) -> CGFloat {
            return { (f: CGFloat) in
                return c * (pow(f, 5) + 1.0) + b
            }(t / d - 1.0)
        }
        
        /// 五次方缓动函数，以慢慢加速的方式开始动画
        public static func easeInQuint(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat = 1.0) -> CGFloat {
            return { (f: CGFloat) in
                c * pow(f, 5) + b
            }(t / d)
        }
        
        /// 回弹缓动函数，以回弹的方式结束动画
        public static func easeOutBack(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat = 1.0) -> CGFloat {
            let s: CGFloat = 2.70158
            let t2: CGFloat = t / d - 1.0
            return CGFloat(c * (t2 * t2 * ((s + 1.0) * t2 + s) + 1.0)) + b
        }
        
        /// 弹跳缓动函数，以弹跳的方式结束动画
        public static func easeOutBounce(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat = 1.0) -> CGFloat {
            return { (f: CGFloat) in
                if f < 1 / 2.75 {
                    return c * 7.5625 * f * f + b
                } else if f < 2 / 2.75 {
                    let t = f - 1.5 / 2.75
                    return c * (7.5625 * t * t + 0.75) + b
                } else if f < 2.5 / 2.75 {
                    let t = f - 2.25 / 2.75
                    return c * (7.5625 * t * t + 0.9375) + b
                } else {
                    let t = f - 2.625 / 2.75
                    return c * (7.5625 * t * t + 0.984375) + b
                }
            }(t / d)
        }
        
    }
    
}
