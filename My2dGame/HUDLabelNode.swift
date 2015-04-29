//
//  cSKLabelNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 07.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//
import SpriteKit

class HUDLabelNode: SKLabelNode {
    override init() {
        super.init()
        
        self.fontName = "Gill Sans Bold"
        self.fontColor = UIColor.whiteColor()
        self.fontSize = 18
        self.position.x -= 1.5
        self.position.y -= 5
    }

    override init(fontNamed fontName: String!) {
        super.init(fontNamed: fontName)
        
        self.fontColor = UIColor.whiteColor()
        self.fontSize = 18
        self.position.x -= 1.5
        self.position.y -= 5
    }
    
    override var text : String{
        didSet{
            if text == oldValue{
                return
            }
            let length = count(self.text)
            switch length{
                case 4:
                    self.fontSize -= 2
                    break
                case 5:
                    self.fontSize -= 2
                    break
                case 6:
                    self.fontSize -= 2
                default:
                    self.fontSize = 18
                    break
            }
            
            //Scale animation
            let scale = SKAction.scaleTo(1.4, duration: 0.1)
            scale.timingMode = .EaseOut
            let scaleBack = SKAction.scaleTo(1, duration: 0.15)
            
            self.runAction(SKAction.sequence([scale, scaleBack]))
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
}