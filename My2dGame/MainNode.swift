//
//  MainNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 11.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit


class MainNode: SKSpriteNode {
    
    let columnsLayer = SKSpriteNode()
    let nextColumnPreviewNode = SKNode()
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init(){
        super.init()
        
        self.size = CGSize(width: ((BlockWidth + BlockWidthOffset) * CGFloat(NumColumns)), height: ((BlockHeight + BlockHeightOffset) * CGFloat(NumRows)))
        
        columnsLayer.size = CGSize(width: ((BlockWidth + BlockWidthOffset) * CGFloat(NumColumns)), height: ((BlockHeight + BlockHeightOffset) * CGFloat(NumRows)))
        
        nextColumnPreviewNode.position = CGPoint(x: columnsLayer.position.x - 50, y: columnsLayer.position.y)
        
        let bottomNumbersLayer = SKSpriteNode()
        for i in 0..<NumColumns{
            let Label = SKLabelNode(fontNamed: "GillSans-Bold")
            Label.fontSize = 10
            Label.fontColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
            Label.text = NSString(format: "%ld", i+1)
            Label.position = CGPoint(x: CGFloat(i) * (BlockWidth+BlockWidthOffset+0.4), y: 0.0)
            bottomNumbersLayer.addChild(Label)
        }
        bottomNumbersLayer.anchorPoint = CGPointZero
        bottomNumbersLayer.position = CGPoint(x: (BlockWidth / 2)-3, y: columnsLayer.position.y - 15)
        
        self.addChild(columnsLayer)
        self.addChild(bottomNumbersLayer)
        self.addChild(nextColumnPreviewNode)
        
        self.columnsLayer.anchorPoint = CGPointZero
        self.userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        var touch: AnyObject? = touches.anyObject()
        var location = touch?.locationInNode(self.columnsLayer)
        let touchedNode = self.nodeAtPoint(location!)
        
        println("*\(location)")

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}