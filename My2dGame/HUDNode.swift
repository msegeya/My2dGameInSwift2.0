//
//  HUDNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 11.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

class HUDNode: SKSpriteNode {
    
    var levelLabelNode = HUDLabelNode()
    var scoreLabelNode = HUDLabelNode()
    var wavesLeftLabelNode = HUDLabelNode()
    var wavesLeftNode: ProgressBarNode = ProgressBarNode()
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init(){
        super.init()
        self.color = UIColor.redColor()
        self.size = CGSize(width: 50, height: 125)
        
        
        //Menu
        let menuButtonNode = SKSpriteNode(imageNamed: "Menu")
        menuButtonNode.position.y -= 12.5
        menuButtonNode.size = CGSize(width: 50, height: 25)
        menuButtonNode.name = "menuButton"
        
        
        //wavesLeft
        wavesLeftNode = ProgressBarNode(imageNamed: "WavesLeft")
        wavesLeftNode.position.y -= 50
        wavesLeftLabelNode = HUDLabelNode()
        wavesLeftNode.addChild(wavesLeftLabelNode)

        
        //score
        let scoreNode = SKSpriteNode(imageNamed: "Score")
        scoreNode.position.y -= 87.5
        scoreNode.size = CGSize(width: 50, height: 25)
        scoreLabelNode = HUDLabelNode()
        scoreNode.addChild(scoreLabelNode)
        
        
        //level
        let levelNode = SKSpriteNode(imageNamed: "Level")
        levelNode.size = CGSize(width: 50, height: 25)
        levelNode.position.y -= 112.5
        levelLabelNode = HUDLabelNode()
        levelNode.addChild(levelLabelNode)
        
        
        self.addChild(levelNode)
        self.addChild(scoreNode)
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