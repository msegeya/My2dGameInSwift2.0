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
        
        self.backgroundColor = UIColor(red:0.184314, green:0.184314, blue:0.184314, alpha:1.0)
    }
    
    override func didMoveToView(view: SKView) {
        let startGameLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        startGameLabel.text = NSLocalizedString("StartGame", comment: "Start Game")
        startGameLabel.fontSize = 26
        startGameLabel.position.y += 40
        startGameLabel.name = "startGame"
        self.addChild(startGameLabel)
        
        let highscoreLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        highscoreLabel.text = NSLocalizedString("Leaderboard", comment: "Leaderboard")
        highscoreLabel.fontSize = 26
        highscoreLabel.position.y = 0
        highscoreLabel.name = "leaderboard"
        self.addChild(highscoreLabel)
        
        let optionsLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        optionsLabel.text = NSLocalizedString("HowToPlay", comment: "How to play")
        optionsLabel.fontSize = 24
        optionsLabel.position.y -= 40
        optionsLabel.name = "howToPlay"
        self.addChild(optionsLabel)
    }
//    func resizeFBButton(){
//        for (id, loginObject) in enumerate(fbLoginView.subviews){
//            if (loginObject.isKindOfClass(UIButton))
//            {
//                let loginButton: UIButton = loginObject as UIButton
//                let loginImage: UIImage = UIImage(named: "Menu")!
//                loginButton.setBackgroundImage(loginImage, forState: UIControlState.Normal)
//                loginButton.setBackgroundImage(nil, forState: UIControlState.Selected)
//                loginButton.setBackgroundImage(nil, forState: UIControlState.Highlighted)
//            }
//            if (loginObject.isKindOfClass(UILabel))
//            {
//                let loginLabel = loginObject as UILabel
//                loginLabel.text = "";
//                loginLabel.frame = CGRectMake(0, 0, 0, 0);
//            }
//        }
//        
//        fbLoginView.frame = CGRectMake(5, 5, 150, 200)
//    }
    
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

