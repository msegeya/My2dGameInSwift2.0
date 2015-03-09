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
    func gameDidExit()
    func musicDidSwitch()
    func soundDidSwitch()
}

class SKPopUpNode: SKSpriteNode {
    
    var popUpBackground: SKSpriteNode = SKSpriteNode()
    var delegate: PopUpDelegate?
    
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
        
        let resumeLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        resumeLabel.text = "Tap to resume"
        resumeLabel.fontColor = UIColor.darkGrayColor()
        resumeLabel.fontSize = 16
        resumeLabel.position.y -= 40
        self.addChild(resumeLabel)
        
        var button = SKSpriteNode(imageNamed: "backButton")
        button.position.x -= 35
        button.name = "backButton"
        self.addChild(button)
        
        button = SKSpriteNode(imageNamed: "musicButton")
        button.position.x = 0
        button.name = "musicButton"
        self.addChild(button)
        
        button = SKSpriteNode(imageNamed: "soundButton")
        button.position.x += 35
        button.name = "soundButton"
        self.addChild(button)
        
        self.hidden = true
    }
    
    func show(){
        self.hidden = false
    }
    
    func hide(){
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
                delegate?.gameDidExit()
                break
            case "musicButton":
                delegate?.musicDidSwitch()
                break
            case "soundButton":
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