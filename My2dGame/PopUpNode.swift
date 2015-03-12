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
    func musicDidSwitch()
    func soundDidSwitch()
}

class SwitchLabelButton: SKLabelNode {
    var initialText: String = ""
    var state: Bool = false{
        didSet{
            if state == true{
                self.text = initialText + " On"
                self.fontColor = UIColor.greenColor()
            }else{
                self.text = initialText + " Off"
                self.fontColor = UIColor.redColor()
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
            self.text = initialText + " On"
            self.fontColor = UIColor.greenColor()
        }else{
            self.text = initialText + " Off"
            self.fontColor = UIColor.redColor()
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
    init(backgroundColor: UIColor, backgroundSize: CGSize) {
        super.init()
        
        popUpBackground = SKSpriteNode(color: backgroundColor, size: backgroundSize)
        self.addChild(popUpBackground)
        
        self.setup()
    }
    
    func setup(){
        self.size = popUpBackground.size
        popUpBackground.name = "backgroundNode"
        self.userInteractionEnabled = true

        
        let backButtonLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        backButtonLabel.text = "Exit"
        backButtonLabel.fontColor = UIColor.darkGrayColor()
        backButtonLabel.fontSize = 24
        backButtonLabel.position.y += 50
        backButtonLabel.name = "backButton"
        self.addChild(backButtonLabel)
        
        switchMusicButtonLabel = SwitchLabelButton(fontNamed: "Gill Sans Bold", text: "Music", state: true)
        switchMusicButtonLabel.fontSize = 24
        switchMusicButtonLabel.position.y += 10
        switchMusicButtonLabel.name = "switchMusicButton"
        self.addChild(switchMusicButtonLabel)
        
        
        switchSoundButtonLabel = SwitchLabelButton(fontNamed: "Gill Sans Bold", text: "Sounds", state: true)
        switchSoundButtonLabel.fontSize = 24
        switchSoundButtonLabel.position.y -= 30
        switchSoundButtonLabel.name = "switchSoundButton"
        self.addChild(switchSoundButtonLabel)
        
        
        let resumeLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        resumeLabel.text = "Tap to resume"
        resumeLabel.fontColor = UIColor.darkGrayColor()
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
                delegate?.musicDidSwitch()
                break
            case "switchSoundButton":
                switchSoundButtonLabel.state = !switchSoundButtonLabel.state
                delegate?.soundDidSwitch()
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