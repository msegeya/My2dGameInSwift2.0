//
//  MenuScene.swift
//  My2dGame
//
//  Created by Karol Kedziora on 07.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene{
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let startGameLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        startGameLabel.text = "Start Game"
        startGameLabel.fontSize = 24
        startGameLabel.position.y += 20
        self.addChild(startGameLabel)
        
        let highscoreLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        highscoreLabel.text = "Highscores"
        highscoreLabel.fontSize = 24
        highscoreLabel.position.y -= 20
        self.addChild(highscoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

