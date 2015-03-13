//
//  MenuScene.swift
//  My2dGame
//
//  Created by Karol Kedziora on 07.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene{
    var thisDelegate: MenuDelegate?
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let startGameLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        startGameLabel.text = "Start Game"
        startGameLabel.fontSize = 26
        startGameLabel.position.y += 40
        startGameLabel.name = "startGame"
        self.addChild(startGameLabel)
        
        let highscoreLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        highscoreLabel.text = "Leaderboard"
        highscoreLabel.fontSize = 26
        highscoreLabel.position.y = 0
        highscoreLabel.name = "leaderboard"
        self.addChild(highscoreLabel)
        
        let optionsLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        optionsLabel.text = "How to play"
        optionsLabel.fontSize = 24
        optionsLabel.position.y -= 40
        optionsLabel.name = "howToPlay"
        self.addChild(optionsLabel)
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
        case "startGame":
            thisDelegate?.startGame()
            break
        case "leaderboard":
           thisDelegate?.showHighscore()
            break
        case "howToPlay":
            //thisDelegate?.showOptions()
            break
        case "":
           
            break
        default:
          
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

