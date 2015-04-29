//
//  LevelUpPopUpNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 12.04.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation
import SpriteKit

protocol LevelUpPopUpDelegate {
    func gameDidgotoNextLevel()
    func gameDidExitToLevelCollection()
}

class LevelUpPopUpNode: SKSpriteNode {
    
    var popUpBackground: SKSpriteNode = SKSpriteNode()
    var delegate: LevelUpPopUpDelegate?
    
    var musicButton = SwitchButton()
    var soundsButton = SwitchButton()
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    init(imageNamed: String, backgroundSize: CGSize, frameSize: CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: frameSize)
        
        popUpBackground = SKSpriteNode(imageNamed: imageNamed)
        popUpBackground.size = backgroundSize
        self.addChild(popUpBackground)
        
        self.setup()
    }
    init(backgroundColor: UIColor, backgroundSize: CGSize, frameSize: CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: frameSize)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        popUpBackground.name = "backgroundNode"
        self.userInteractionEnabled = true
        
        let backButton = SKSpriteNode(imageNamed: "Exit")
        backButton.size = CGSize(width: 50, height: 50)
        backButton.position.x -= 55
        backButton.position.y += 10
        backButton.name = "backButton"
        addChild(backButton)
        
        musicButton = SwitchButton(onStateImageNamed: "MusicOn", offStateImageNamed: "MusicOff", state: audio.music)
        musicButton.size = CGSize(width: 50, height: 50)
        musicButton.position.y += 10
        musicButton.name = "switchMusicButton"
        addChild(musicButton)
        
        soundsButton = SwitchButton(onStateImageNamed: "SoundsOn", offStateImageNamed: "SoundsOff", state: audio.sounds)
        soundsButton.size = CGSize(width: 50, height: 50)
        soundsButton.position.x += 55
        soundsButton.position.y += 10
        soundsButton.name = "switchSoundsButton"
        addChild(soundsButton)
        
        let resumeLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        resumeLabel.text = NSLocalizedString("TapToResume", comment: "Tap to resume")
        resumeLabel.fontColor = UIColor.whiteColor()
        resumeLabel.fontSize = 14
        resumeLabel.position.y -= 35
        self.addChild(resumeLabel)
        
        self.hidden = true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            var location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            
            
            var nodeName: String = ""
            if(touchedNode.name != nil){
                nodeName = "\(touchedNode.name!)"
            }
            
            switch nodeName{
            case "backButton":
                //delegate?.gameDidExitToMenu()
                break
            case "switchMusicButton":
                musicButton.state = !musicButton.state
                audio.music = !audio.music
                break
            case "switchSoundsButton":
                soundsButton.state = !soundsButton.state
                audio.sounds = !audio.sounds
                break
            case "":
                //delegate?.gameDidResume()
                break
            default:
                //delegate?.gameDidResume()
                break
            }
        }
    }
}