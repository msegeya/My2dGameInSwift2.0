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
        startGameLabel.position.y += 20
        startGameLabel.name = "startGame"
        self.addChild(startGameLabel)
        
        let highscoreLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        highscoreLabel.text = "Highscores"
        highscoreLabel.fontSize = 26
        highscoreLabel.position.y -= 20
        highscoreLabel.name = "highscores"
        self.addChild(highscoreLabel)
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
        case "highscores":
           thisDelegate?.showHighscore()
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

