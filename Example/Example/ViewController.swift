//
//  ViewController.swift
//  Example
//
//  Created by 陈卓 on 2023/7/28.
//

import UIKit
import ThenMorphingLabel

class ViewController : UIViewController {
    
    fileprivate var i = -1
    fileprivate var textArray = [
        "What is design?",
        "Design",
        "Design is not just",
        "what it looks like",
        "and feels like.",
        "Design",
        "is how it works.",
        "- Steve Jobs",
        "Older people",
        "sit down and ask,",
        "'What is it?'",
        "but the boy asks,",
        "'What can I do with it?'.",
        "- Steve Jobs",
        "One more thing...",
        "Swift",
        "Objective-C",
        "iPhone", "iPad",
        "Mac Mini", "MacBook Pro🔥", "Mac Pro⚡️",
        "爱老婆",
        "नमस्ते दुनिया",
        "हिन्दी भाषा",
        "$68.98",
        "$68.99",
        "$69.00",
        "$69.01"
    ]
    fileprivate var text: String {
        i = i >= textArray.count - 1 ? 0 : i + 1
        return textArray[i]
    }
    
    @IBOutlet weak var effectSegmentControl: UISegmentedControl!
    @IBOutlet weak var themeSegmentControl: UISegmentedControl!
    @IBOutlet fileprivate var label: ThenMorphingLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 如果进行数字跳动动画: 因为数字的宽度不一致, 会造成视觉差异, 可以设定为宽度一致来避免
        label.isNumberEqual = true
        label.delegate = self
        label.font = UIFont.boldSystemFont(ofSize: 40)
        
        [effectSegmentControl, themeSegmentControl].forEach {
            $0?.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .normal)
            $0?.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        }
    }
    
    @IBAction func changeText(_ sender: AnyObject) {
        label.text = text
        if !autoStart.isOn {
            label.pause()
            progressSlider.value = 0
        }
    }

    @IBAction func clear(_ sender: Any) {
        label.text = nil
    }
    
    @IBOutlet weak var autoStart: UISwitch!
    
    @IBAction func updateAutoStart(_ sender: Any) {
        progressSlider.isHidden = autoStart.isOn
        if autoStart.isOn {
            label.resume()
        } else {
            changeText(NSObject())
        }
    }
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBAction func updateProgress(_ sender: Any) {
        label.morphingProgress = CGFloat(progressSlider.value / 100)
        label.setNeedsDisplay()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let seg = sender
        if let effect = ThenMorphingLabel.Effect(rawValue: seg.selectedSegmentIndex) {
            label.morphingEffect = effect
            changeText(sender)
        }
    }

    @IBAction func toggleLight(_ sender: UISegmentedControl) {
        let isNight = Bool(sender.selectedSegmentIndex == 0)
        view.backgroundColor = isNight ? UIColor.black : UIColor.white
        label.textColor = isNight ? UIColor.white : UIColor.black
    }
    
    @IBAction func changeFontSize(_ sender: UISlider) {
        label.font = UIFont(descriptor: label.font.fontDescriptor, size: CGFloat(sender.value))
        label.text = label.text
    }
}

// MARK: - ThenMorphingLabelDelegate
extension ViewController: ThenMorphingLabelDelegate {
    
    func morphingDidStart(_ label: ThenMorphingLabel) {
        
    }
    
    func morphingDidComplete(_ label: ThenMorphingLabel) {
        
    }
    
    func morphingOnProgress(_ label: ThenMorphingLabel, progress: CGFloat) {
        
    }
    
}
