//
//  popUp.swift
//  My2dGame
//
//  Created by Karol Kedziora on 07.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

protocol PopUpDelegate {
    func gameDidResume()
    func gameDidExitToMenu()
}

class SwitchLabelButton: SKLabelNode {
    var initialText: String = ""
    var state: Bool = false{
        didSet{
            if state == true{
                self.text = initialText + " " + NSLocalizedString("On", comment: "On")
                self.fontColor = UIColor(red:0.298039, green:0.760784, blue:0.282353, alpha:1.0)
            }else{
                self.text = initialText + " " + NSLocalizedString("Off", comment: "Off")
                self.fontColor = UIColor(red:0.780392, green:0.243137, blue:0.219608, alpha:1.0)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    override init(fontNamed fontName: String!) {
        super.init(fontNamed: fontName)
    }
    
    init(fontNamed fontName: String!, text: String!, state: Bool){
        super.init(fontNamed: fontName)
        self.initialText = text
        self.state = state
        
        if state == true{
            self.text = initialText + " " + NSLocalizedString("On", comment: "On")
            self.fontColor = UIColor(red:0.298039, green:0.760784, blue:0.282353, alpha:1.0)
        }else{
            self.text = initialText + " " + NSLocalizedString("Off", comment: "Off")
            self.fontColor = UIColor(red:0.780392, green:0.243137, blue:0.219608, alpha:1.0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SwitchButton: SKSpriteNode {
    var onStateImage = SKTexture()
    var offStateImage = SKTexture()
    
    var state: Bool = false{
        didSet{
            if state == true{
                self.texture = onStateImage
            }else{
                self.texture = offStateImage
            }
        }
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init() {
        super.init()
    }
    
    init(onStateImageNamed: String, offStateImageNamed: String, state: Bool) {
        super.init()
        
        self.onStateImage = SKTexture(imageNamed: onStateImageNamed)
        self.offStateImage = SKTexture(imageNamed: offStateImageNamed)
        
        self.state = state
        
        if state{
            self.texture = onStateImage
        }else{
            self.texture = offStateImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopUpNode: SKSpriteNode {
    
    var popUpBackground: SKSpriteNode = SKSpriteNode()
    var delegate: PopUpDelegate?
    
    var musicButton = SwitchButton()
    var soundsButton = SwitchButton()
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init() {
        super.init()
    }
    
    init(imageNamed: String, backgroundSize: CGSize, frameSize: CGSize) {
        super.init()
        self.size = frameSize
        popUpBackground = SKSpriteNode(imageNamed: imageNamed)
        popUpBackground.size = backgroundSize
        self.addChild(popUpBackground)
        
        self.setup()
    }
    init(backgroundColor: UIColor, backgroundSize: CGSize, frameSize: CGSize) {
        super.init()
        self.size = frameSize
        popUpBackground = SKSpriteNode(color: backgroundColor, size: backgroundSize)
        self.addChild(popUpBackground)
        
        self.setup()
    }
    
    func setup(){
        popUpBackground.name = "backgroundNode"
        self.userInteractionEnabled = true

        let backButton = SKSpriteNode(imageNamed: "Exit")
        backButton.size = CGSize(width: 50, height: 50)
        backButton.position.x -= 55
        backButton.position.y += 10
        backButton.name = "backButton"
        addChild(backButton)
        
        musicButton = SwitchButton(onStateImageNamed: "MusicOn", offStateImageNamed: "MusicOff", state: audio.music)
        musicButton.size = CGSize(width: 50, height: 50)
        musicButton.position.y += 10
        musicButton.name = "switchMusicButton"
        addChild(musicButton)
        
        soundsButton = SwitchButton(onStateImageNamed: "SoundsOn", offStateImageNamed: "SoundsOff", state: audio.sounds)
        soundsButton.size = CGSize(width: 50, height: 50)
        soundsButton.position.x += 55
        soundsButton.position.y += 10
        soundsButton.name = "switchSoundsButton"
        addChild(soundsButton)

        let resumeLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        resumeLabel.text = NSLocalizedString("TapToResume", comment: "Tap to resume")
        resumeLabel.fontColor = UIColor.whiteColor()
        resumeLabel.fontSize = 14
        resumeLabel.position.y -= 35
        self.addChild(resumeLabel)
        
        self.hidden = true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        var touch: AnyObject? = touches.anyObject()
        var location = touch?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        
        var nodeName: String = ""
        if(touchedNode.name != nil){
            nodeName = "\(touchedNode.name!)"
        }
        
        switch nodeName{
            case "backButton":
                delegate?.gameDidExitToMenu()
                break
            case "switchMusicButton":
                musicButton.state = !musicButton.state
                audio.music = !audio.music
                break
            case "switchSoundsButton":
                soundsButton.state = !soundsButton.state
                audio.sounds = !audio.sounds
                break
            case "":
                delegate?.gameDidResume()
                break
            default:
                delegate?.gameDidResume()
                break
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
}