import UIKit
import Foundation
import QuartzCore

// MARK: - Operate
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?): return l < r
    case (nil, _?):    return true
    default:           return false
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?): return l >= r
    default:           return !(lhs < rhs)
    }
}

// MARK: - Phases
extension ThenMorphingLabel {
    enum Phases: Int {
        case start, appear, disappear, draw, progress, skipFrames
    }
}

// MARK: - ThenMorphingLabelDelegate
@objc public protocol ThenMorphingLabelDelegate {
    
    @objc optional func morphingDidStart(_ label: ThenMorphingLabel)
    
    @objc optional func morphingOnProgress(_ label: ThenMorphingLabel, progress: CGFloat)
    
    @objc optional func morphingDidComplete(_ label: ThenMorphingLabel)
}


// MARK: - Typealias Closure
typealias MorphingStartClosure = () -> ()

typealias MorphingEffectClosure = (Character, _ index: Int, _ progress: CGFloat) -> ThenMorphingLabel.CharacterItem

typealias MorphingDrawingClosure = (ThenMorphingLabel.CharacterItem) -> Bool

typealias MorphingManipulateProgressClosure = (_ index: Int, _ progress: CGFloat, _ isNewChar: Bool) -> CGFloat

typealias MorphingSkipFramesClosure = () -> Int


// MARK: - ThenMorphingLabel
@IBDesignable open class ThenMorphingLabel: UILabel {
    
    // MARK: - Deleagte
    @IBOutlet open weak var delegate: ThenMorphingLabelDelegate?
    
    // MARK: - Public Properties
    
    // 变形动画的进度、持续时间、字符延迟和启用/禁用标志等属性
    @IBInspectable open var morphingProgress: CGFloat = 0.0
    @IBInspectable open var morphingDuration: CGFloat = 0.6
    @IBInspectable open var morphingCharacterDelay: CGFloat = 0.026
    @IBInspectable open var morphingEnabled: Bool = true
    
    /// 动画类别
    open var morphingEffect: Effect = .scale
    
    /// 数字字符的宽度是否一致
    open var isNumberEqual: Bool = false
    
    
    // MARK: - Private Properties
    
    // 自定义变形动画
    var startClosures      = [String : MorphingStartClosure]()
    var effectClosures     = [String : MorphingEffectClosure]()
    var drawingClosures    = [String : MorphingDrawingClosure]()
    var progressClosures   = [String : MorphingManipulateProgressClosure]()
    var skipFramesClosures = [String : MorphingSkipFramesClosure]()
    
    // 存储文本差异比较结果
    var diffResults: ([ThenMorphingLabel.CharacterDifference], skipDrawingResults: [Bool])?
    // 上一次的文本内容
    var previousText = ""
    
    // 当前帧
    var currentFrame = 0
    // 总帧数
    var totalFrames = 0
    // 总延迟帧数
    var totalDelayFrames = 0
    // 跳帧计数
    var skipFramesCount: Int = 0
    // 字符高度
    var charHeight: CGFloat = 0.0
    
    // 总宽度、以及上一次和新的每个字符的矩形区域
    var totalWidth: CGFloat = 0.0
    var previousRects = [CGRect]()
    var newRects      = [CGRect]()
    
    var displayLink: CADisplayLink?
    
    var tempRenderMorphingEnabled = true
    
#if TARGET_INTERFACE_BUILDER
    let presentingInIB = true
#else
    let presentingInIB = false
#endif
    
    // MARK: - Display Operate
    
    open func start() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(displayFrameTick))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    open func pause() { displayLink?.isPaused = true }
    
    open func resume() { displayLink?.isPaused = false }
    
    open func finish() { displayLink?.isPaused = false }
    
    open func stop() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink?.invalidate()
        displayLink = nil
    }
    
    
    // MARK: - override
    
    open var textAttributes: [NSAttributedString.Key: Any]? {
        didSet { setNeedsLayout() }
    }
    
    override open var font: UIFont! {
        get { super.font ?? UIFont.systemFont(ofSize: 15) }
        set {
            super.font = newValue
            setNeedsLayout()
        }
    }
    
    override open var text: String? {
        get { super.text ?? "" }
        set {
            guard text != newValue else { return }
            
            previousText = text ?? ""
            diffResults = previousText.difference(newValue)
            super.text = newValue ?? ""
            
            morphingProgress = 0.0
            currentFrame = 0
            totalFrames = 0
            
            tempRenderMorphingEnabled = morphingEnabled
            setNeedsLayout()
            
            if !morphingEnabled {
                return
            }
            
            if presentingInIB {
                morphingDuration = 0.01
                morphingProgress = 0.5
            } else if previousText != text {
                start()
                let closureKey = "\(morphingEffect.description)\(Phases.start)"
                if let closure = startClosures[closureKey] {
                    return closure()
                }
                
                delegate?.morphingDidStart?(self)
            }
        }
    }
    
    override open var bounds: CGRect {
        get { super.bounds }
        set {
            super.bounds = newValue
            setNeedsLayout()
        }
    }
    
    override open var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue
            setNeedsLayout()
        }
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        previousRects = rectsOfEachCharacter(previousText, withFont: font)
        newRects = rectsOfEachCharacter(text ?? "", withFont: font)
    }
    
    // MARK: - Lifecycle
    deinit { stop() }
    
    
    // MARK: - Views
    lazy var emitterView: EmitterView = {
        let emitterView = EmitterView(frame: self.bounds)
        self.addSubview(emitterView)
        return emitterView
    }()
    
}

// MARK: - Animation extension
extension ThenMorphingLabel {
    
    public func updateProgress(progress: CGFloat) {
        guard let displayLink = displayLink else { return }
        
        // 计算总帧数和总延迟帧数
        if displayLink.duration > 0.0 && totalFrames == 0 {
            let frameInterval = displayLink.preferredFramesPerSecond == 30 ? 2 : 1
            let frameRate = CGFloat(displayLink.duration) / CGFloat(frameInterval)
            totalFrames = Int(ceil(morphingDuration / frameRate))
            
            let totalDelay = CGFloat(text?.count ?? 0) * morphingCharacterDelay
            totalDelayFrames = Int(ceil(totalDelay / frameRate))
        }
        currentFrame = Int(ceil(progress * CGFloat(totalFrames)))
        
        // 如果文本内容有变化，则更新变形动画的进度属性 morphingProgress，并更新显示
        if previousText != text && currentFrame < totalFrames + totalDelayFrames + 10 {
            morphingProgress = progress
            
            // 判断是否需要跳帧
            let closureKey = "\(morphingEffect.description)\(Phases.skipFrames)"
            if let closure = skipFramesClosures[closureKey] {
                skipFramesCount += 1
                if skipFramesCount > closure() {
                    skipFramesCount = 0
                    setNeedsDisplay()
                }
            } else {
                setNeedsDisplay()
            }
            delegate?.morphingOnProgress?(self, progress: morphingProgress)
        } else {
            stop()
            delegate?.morphingDidComplete?(self)
        }
    }
    
    @objc func displayFrameTick() {
        if totalFrames == 0 {
            updateProgress(progress: 0)
        } else {
            morphingProgress += 1.0 / CGFloat(totalFrames)
            updateProgress(progress: morphingProgress)
        }
    }
    
    // 计算每个字符的Frame
    // Could be enhanced by kerning text:
    // http://stackoverflow.com/questions/21443625/core-text-calculate-letter-frame-in-ios
    func rectsOfEachCharacter(_ text: String, withFont font: UIFont) -> [CGRect] {
        var charRects = [CGRect]()
        var leftOffset: CGFloat = 0.0
        
        let attributes = [NSAttributedString.Key.font: font]
        let numSize = "0123456789"
            .map { String($0).size(withAttributes: attributes) }
            .max { $0.width < $1.width } ?? .zero
        // 计算字符高度
        charHeight = "Leg".size(withAttributes: attributes).height
        // 计算字符顶部偏移量
        let topOffset = (bounds.size.height - charHeight) / 2.0
        //
        for char in text {
            let charSize: CGSize
            if isNumberEqual && char.isNumber {
                charSize = numSize
            } else {
                charSize = String(char).size(withAttributes: attributes)
            }
            charRects.append(
                CGRect(
                    origin: CGPoint(
                        x: leftOffset,
                        y: topOffset
                    ),
                    size: charSize
                )
            )
            leftOffset += charSize.width
        }
        // 文本总宽度
        totalWidth = leftOffset
        
        // 计算字符串左侧偏移量（水平对齐方式为居中或右侧时有用）
        var stringLeftOffSet: CGFloat = 0.0
        switch textAlignment {
        case .center: stringLeftOffSet = (bounds.size.width - totalWidth) / 2.0
        case .right:  stringLeftOffSet = (bounds.size.width - totalWidth)
        default: break
        }
        // 对每个字符的进行偏移
        let offsetedCharRects = charRects.map { $0.offsetBy(dx: stringLeftOffSet, dy: 0.0) }
        return offsetedCharRects
    }
    
    // 计算原始字符的位置和动画效果
    func limboOfOriginalCharacter(
        _ char: Character,
        index: Int,
        progress: CGFloat) -> CharacterItem {
            
            var currentRect = previousRects[index]
            let oriX = currentRect.origin.x
            var newX = currentRect.origin.x
            var currentFontSize = font.pointSize
            var currentAlpha: CGFloat = 1.0
            
            switch diffResults?.0[index] {
                // 将存在于新文本中的字符移动到指定位置
            case .same:
                newX = newRects[index].origin.x
                currentRect.origin.x = Easing.easeOutQuint(progress, oriX, newX - oriX)
            case .move(let offset):
                newX = newRects[index + offset].origin.x
                currentRect.origin.x = Easing.easeOutQuint(progress, oriX, newX - oriX)
            case .moveAndAdd(let offset):
                newX = newRects[index + offset].origin.x
                currentRect.origin.x = Easing.easeOutQuint(progress, oriX, newX - oriX)
            default:
                // 删除
                // 通过扩展中的闭包覆盖变形效果
                if let closure = effectClosures[
                    "\(morphingEffect.description)\(Phases.disappear)"
                ] {
                    return closure(char, index, progress)
                } else {
                    // 默认进行缩放
                    let fontEase = Easing.easeOutQuint(progress, 0, font.pointSize)
                    // For emojis
                    currentFontSize = max(0.0001, font.pointSize - fontEase)
                    currentAlpha = 1.0 - progress
                    currentRect = previousRects[index].offsetBy(
                        dx: 0,
                        dy: CGFloat(font.pointSize - currentFontSize)
                    )
                }
            }
            
            return CharacterItem(
                char: char,
                rect: currentRect,
                alpha: currentAlpha,
                size: currentFontSize,
                drawingProgress: 0.0
            )
        }
    
    // 计算新字符的位置和动画效果
    func limboOfNewCharacter(
        _ char: Character,
        index: Int,
        progress: CGFloat) -> CharacterItem {
            
            let currentRect = newRects[index]
            var currentFontSize = Easing.easeOutQuint(progress, 0, font.pointSize)
            
            if let closure = effectClosures[
                "\(morphingEffect.description)\(Phases.appear)"
            ] {
                return closure(char, index, progress)
            } else {
                currentFontSize = Easing.easeOutQuint(progress, 0.0, font.pointSize)
                // For emojis
                currentFontSize = max(0.0001, currentFontSize)
                
                let yOffset = font.pointSize - currentFontSize
                
                return CharacterItem(
                    char: char,
                    rect: currentRect.offsetBy(dx: 0, dy: yOffset),
                    alpha: morphingProgress,
                    size: currentFontSize,
                    drawingProgress: 0.0
                )
            }
        }
    
    // 计算所有字符的动画
    func limboOfCharacters() -> [CharacterItem] {
        var limbo = [CharacterItem]()
        
        // Iterate original characters
        for (i, character) in previousText.enumerated() {
            var progress: CGFloat = 0.0
            
            if let closure = progressClosures[
                "\(morphingEffect.description)\(Phases.progress)"
            ] {
                progress = closure(i, morphingProgress, false)
            } else {
                progress = min(1.0, max(0.0, morphingProgress + morphingCharacterDelay * CGFloat(i)))
            }
            
            let limboOfCharacter = limboOfOriginalCharacter(character, index: i, progress: progress)
            limbo.append(limboOfCharacter)
        }
        
        // Add new characters
        for (i, character) in (text!).enumerated() {
            if i >= diffResults?.0.count {
                break
            }
            
            var progress: CGFloat = 0.0
            
            if let closure = progressClosures[
                "\(morphingEffect.description)\(Phases.progress)"
            ] {
                progress = closure(i, morphingProgress, true)
            } else {
                progress = min(1.0, max(0.0, morphingProgress - morphingCharacterDelay * CGFloat(i)))
            }
            
            // Don't draw character that already exists
            if diffResults?.skipDrawingResults[i] == true {
                continue
            }
            
            switch diffResults?.0[i] {
            case .moveAndAdd, .replace, .add, .delete:
                let limboOfCharacter = limboOfNewCharacter(
                    character,
                    index: i,
                    progress: progress
                )
                limbo.append(limboOfCharacter)
            default:
                ()
            }
        }
        
        return limbo
    }
    
}

// MARK: - Drawing extension
extension ThenMorphingLabel {
    
    override open func didMoveToSuperview() {
        guard nil != superview else {
            stop()
            return
        }
        
        if let s = text {
            text = s
        }
        
        // Load all morphing effects
        Effect.allValues.forEach {
            let effectFunc = Selector("\($0)Load")
            if responds(to: effectFunc) {
                perform(effectFunc)
            }
        }
    }
    
    override open func drawText(in rect: CGRect) {
        if !tempRenderMorphingEnabled || limboOfCharacters().isEmpty {
            super.drawText(in: rect)
            return
        }
        
        for charLimbo in limboOfCharacters() {
            let charRect = charLimbo.rect
            
            let willAvoidDefaultDrawing: Bool = {
                if let closure = drawingClosures[
                    "\(morphingEffect.description)\(Phases.draw)"
                ] {
                    return closure($0)
                }
                return false
            }(charLimbo)
            
            if !willAvoidDefaultDrawing {
                var attrs: [NSAttributedString.Key: Any] = [
                    .foregroundColor: textColor.withAlphaComponent(charLimbo.alpha),
                    .font: UIFont(descriptor: font.fontDescriptor, size: charLimbo.size)
                ]
                for (key, value) in textAttributes ?? [:] {
                    attrs[key] = value
                }
                let s = String(charLimbo.char)
                s.draw(in: charRect, withAttributes: attrs)
            }
        }
    }
    
}
