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
        
        //level
        let levelNode = SKSpriteNode(imageNamed: "Level")
        levelNode.size = CGSize(width: 50, height: 50)
        levelLabelNode = HUDLabelNode()
        levelNode.addChild(levelLabelNode)
        
        
        //score
        let scoreNode = SKSpriteNode(imageNamed: "Score")
        scoreNode.position.y -= 50
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreLabelNode = HUDLabelNode()
        scoreNode.addChild(scoreLabelNode)
        
        
        //wavesLeft
        wavesLeftNode = ProgressBarNode(imageNamed: "WavesLeft100px")
        wavesLeftNode.position.y -= 100
        wavesLeftLabelNode = HUDLabelNode()
        wavesLeftNode.addChild(wavesLeftLabelNode)
        
        
        //Menu
        let menuButtonNode = SKSpriteNode(imageNamed: "Menu")
        menuButtonNode.position.y -= 200
        menuButtonNode.size = CGSize(width: 50, height: 50)
        menuButtonNode.name = "menuButton"
        
        
        self.addChild(levelNode)
        self.addChild(scoreNode)
        self.addChild(wavesLeftNode)
        self.addChild(menuButtonNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}