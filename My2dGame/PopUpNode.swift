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

class PopUpNode: SKSpriteNode {
    
    var popUpBackground: SKSpriteNode = SKSpriteNode()
    var delegate: PopUpDelegate?
    
    var switchMusicButtonLabel = SwitchLabelButton()
    var switchSoundButtonLabel = SwitchLabelButton()
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init() {
        super.init()
    }
    
    init(imageNamed: String, backgroundSize: CGSize) {
        super.init()
        
        popUpBackground = SKSpriteNode(fileNamed: imageNamed)
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

        
        let backButtonLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        backButtonLabel.text = NSLocalizedString("Exit", comment: "Exit")
        backButtonLabel.fontColor = UIColor.whiteColor()
        backButtonLabel.fontSize = 24
        backButtonLabel.position.y += 50
        backButtonLabel.name = "backButton"
        self.addChild(backButtonLabel)
        
        switchMusicButtonLabel = SwitchLabelButton(fontNamed: "Gill Sans Bold", text: NSLocalizedString("Music", comment: "Music") , state: audio.music)
        switchMusicButtonLabel.fontSize = 24
        switchMusicButtonLabel.position.y += 10
        switchMusicButtonLabel.name = "switchMusicButton"
        self.addChild(switchMusicButtonLabel)
        
        switchSoundButtonLabel = SwitchLabelButton(fontNamed: "Gill Sans Bold", text: NSLocalizedString("Sounds", comment: "Sounds") , state: audio.sounds)
        switchSoundButtonLabel.fontSize = 24
        switchSoundButtonLabel.position.y -= 30
        switchSoundButtonLabel.name = "switchSoundButton"
        self.addChild(switchSoundButtonLabel)
        
        
        let resumeLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        resumeLabel.text = NSLocalizedString("TapToResume", comment: "Tap to resume")
        resumeLabel.fontColor = UIColor.whiteColor()
        resumeLabel.fontSize = 24
        resumeLabel.position.y -= 70
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
                switchMusicButtonLabel.state = !switchMusicButtonLabel.state
                audio.music = !audio.music
                break
            case "switchSoundButton":
                switchSoundButtonLabel.state = !switchSoundButtonLabel.state
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