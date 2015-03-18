//
//  HUDNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 11.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

class HUDNode: SKSpriteNode {
    var wavesLeftLabelNode = HUDLabelNode()
    var wavesLeftNode: ProgressBarNode = ProgressBarNode()
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init(){
        super.init()
        //self.color = UIColor.redColor()
        self.size = CGSize(width: 50, height: 100)
        
        
        //Menu
        let menuButtonNode = SKSpriteNode(imageNamed: "Menu")
        menuButtonNode.position.y -= 46
        menuButtonNode.size = CGSize(width: 50, height: 50)
        menuButtonNode.name = "menuButton"
        
        
        //wavesLeft
        wavesLeftNode = ProgressBarNode(imageNamed: "wavesLeft")
        wavesLeftNode.position.y -= 106
        wavesLeftLabelNode = HUDLabelNode()
        wavesLeftNode.addChild(wavesLeftLabelNode)
        

        self.addChild(wavesLeftNode)
        self.addChild(menuButtonNode)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        var touch: AnyObject? = touches.anyObject()
        var location = touch?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name != nil{
            if touchedNode.name! == "menuButton"{
                NSNotificationCenter.defaultCenter().postNotificationName("pauseGameScene", object: nil)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}