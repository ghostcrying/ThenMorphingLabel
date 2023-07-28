# ThenMorphingLabel

Fork from [LTMorphingLabel](https://github.com/lexrus/LTMorphingLabel) 

A morphing UILabel subclass written in Swift.
The ```.Scale``` effect mimicked [Apple's QuickType animation of iOS 8](https://youtu.be/w87fOAG8fjk?t=3451) of WWDC 2014. New morphing effects are available as Swift extensions.

## enum ThenMorphingLabel.Effect: Int, Printable

#### .Scale - _default_
<img src="https://cloud.githubusercontent.com/assets/219689/3491822/96bf5de6-059d-11e4-9826-a6f82025d1af.gif" width="300" height="70" alt="LTMorphingLabel"/>

#### [.Evaporate](https://github.com/lexrus/LTMorphingLabel/blob/master/LTMorphingLabel/LTMorphingLabel%2BEvaporate.swift)
<img src="https://cloud.githubusercontent.com/assets/219689/3491838/ffc5aff2-059d-11e4-970c-6e2d7664785a.gif" width="300" height="70" alt="LTMorphingLabel-Evaporate"/>

#### [.Fall](https://github.com/lexrus/LTMorphingLabel/blob/master/LTMorphingLabel/LTMorphingLabel%2BFall.swift)
<img src="https://cloud.githubusercontent.com/assets/219689/3491840/173c2238-059e-11e4-9b33-dcd21edae9e2.gif" width="300" height="70" alt="LTMorphingLabel-Fall"/>

#### [.Pixelate](https://github.com/lexrus/LTMorphingLabel/blob/master/LTMorphingLabel/LTMorphingLabel%2BPixelate.swift)
<img src="https://cloud.githubusercontent.com/assets/219689/3491845/29bb0f8c-059e-11e4-9ef8-de56bec1baba.gif" width="300" height="70" alt="LTMorphingLabel-Pixelate"/>

#### [.Sparkle](https://github.com/lexrus/LTMorphingLabel/blob/master/LTMorphingLabel/LTMorphingLabel%2BSparkle.swift)
<img src="https://cloud.githubusercontent.com/assets/219689/3508789/31e9fafe-0690-11e4-9a76-ba3ef45eb53a.gif" width="300" height="70" alt="LTMorphingLabel-Sparkle"/>

```.Sparkle``` is built on top of QuartzCore.CAEmitterLayer. There's also a [SpriteKit powered version here](https://github.com/lexrus/LTMorphingLabel/blob/spritekit-sparkle/LTMorphingLabel/LTMorphingLabel%2BSparkle.swift).

#### [.Burn](https://github.com/lexrus/LTMorphingLabel/blob/master/LTMorphingLabel/LTMorphingLabel%2BBurn.swift)
<img src="https://cloud.githubusercontent.com/assets/219689/358258 6/4fb8c52e-0bfe-11e4-9b6f-f070f7f3ab55.gif" width="300" height="70" alt="LTMorphingLabel-Burn"/>

#### [.Anvil](https://github.com/lexrus/LTMorphingLabel/blob/master/LTMorphingLabel/LTMorphingLabel%2BAnvil.swift)
<img src="https://cloud.githubusercontent.com/assets/219689/3594949/815cd3e8-0caa-11e4-9738-278a9c959478.gif" width="300" height="70" alt="LTMorphingLabel-Anvil"/>

## SwiftUI

```swift
public var body: some View {
    VStack {
        MorphingText(
            "Awesome Morphing Text",
            effect: .evaporate,
            font: UIFont.systemFont(ofSize: 20),
            textColor: .black,
            textAlignment: .center
        ).frame(maxWidth: 200, maxHeight: 100)
        ...
```

## Requirements

1. iOS 11.0+

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

1. File > Swift Packages > Add Package Dependency
2. Copy & paste `https://github.com/ghostcrying/ThenMorphingLabel` then follow the instruction

### [Carthage](https://github.com/Carthage/Carthage)

1. Add this line to your Cartfile: `github "ghostcrying/ThenMorphingLabel"`
2. Read the [official instruction](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### [CocoaPods](http://cocoapods.org)

1. Install the latest release of CocoaPods: `gem install cocoapods`
2. Add this line to your Podfile: `pod 'LTMorphingLabel'`
3. Install the pod: `pod install`

## Usage

1. Change the class of a label from UILabel to LTMorphingLabel;
2. Programmatically set a new String to its text property.
3. To use interactively, call `.pause()` after changing `.text` property, and use `updateProgress(progress: Float)`to update the progress interactively.
