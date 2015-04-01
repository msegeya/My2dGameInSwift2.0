//
//  MainNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 11.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

protocol ColumnLayerDelegate{
    func BlockDidTap(location: CGPoint)
    func ColumnDidSwipe(location: CGPoint, direction: Direction)
    func HorizontalSwipeDetected(location: CGPoint, direction: Direction)
}

struct Swipe {
    var location: CGPoint
    var direction: Direction
}

class MainNode: SKSpriteNode {
    let columnsLayer = SKSpriteNode()
    let nextColumnPreviewNode = SKNode()
    var delegate: ColumnLayerDelegate?
    
    var levelLabelNode = HUDLabelNode()
    var scoreLabelNode = HUDLabelNode()
    
    var tapLocation: CGPoint?
    var swipe: Swipe?
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    override init(){
        super.init()
        
        self.size = CGSize(width: ((BlockWidth + BlockWidthOffset) * CGFloat(NumColumns)), height: ((BlockHeight + BlockHeightOffset) * CGFloat(NumRows)))
        
        //columnsLayer.size = CGSize(width: ((BlockWidth + BlockWidthOffset) * CGFloat(NumColumns)), height: ((BlockHeight + BlockHeightOffset) * CGFloat(NumRows)))
        
        nextColumnPreviewNode.position = CGPoint(x: columnsLayer.position.x - 50, y: columnsLayer.position.y + 10)
        
        let bottomNumbersLayer = SKSpriteNode()
        for i in 0..<NumColumns{
            let Label = SKLabelNode(fontNamed: "GillSans-Bold")
            Label.fontSize = 10
            Label.fontColor = UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1)
            Label.text = NSString(format: "%ld", i+1)
            Label.position = CGPoint(x: CGFloat(i) * (BlockWidth+BlockWidthOffset+0.4), y: 0.0)
            bottomNumbersLayer.addChild(Label)
        }
        bottomNumbersLayer.anchorPoint = CGPointZero
        bottomNumbersLayer.position = CGPoint(x: (BlockWidth / 2)-3, y: columnsLayer.position.y - 16)
        
        self.addChild(columnsLayer)
        self.addChild(bottomNumbersLayer)
        self.addChild(nextColumnPreviewNode)
        
        self.columnsLayer.anchorPoint = CGPointZero
        self.userInteractionEnabled = true
        

        //level
        levelLabelNode = HUDLabelNode()
        levelLabelNode.position.x += 310
        levelLabelNode.position.y += self.size.height - 15
        
        
        //score
        scoreLabelNode = HUDLabelNode()
        scoreLabelNode.position.x += 420
        scoreLabelNode.position.y += self.size.height - 15
        
        addChild(levelLabelNode)
        addChild(scoreLabelNode)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        var touch: AnyObject? = touches.anyObject()
        var location = touch?.locationInNode(self.columnsLayer)

        tapLocation = location!
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if swipe != nil{
            return
        }

        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(self.columnsLayer)
        
        if (location.y - tapLocation!.y) > BlockHeight*1.5{
            swipe = Swipe(location: location, direction: Direction.Up)
        }else if (location.y - tapLocation!.y) < -(BlockHeight*1.5){
            swipe = Swipe(location: location, direction: Direction.Down)
        }else if (location.x - tapLocation!.x) < -(BlockWidth*1.5){
            swipe = Swipe(location: location, direction: Direction.Right)
        }else if (location.x - tapLocation!.y) > BlockWidth*1.5{
            swipe = Swipe(location: location, direction: Direction.Left)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if swipe != nil{
            if swipe!.direction == .Up || swipe!.direction == .Down{
                delegate?.ColumnDidSwipe(tapLocation!, direction: swipe!.direction)
            }else{
                delegate?.HorizontalSwipeDetected(tapLocation!, direction: swipe!.direction)
            }
            
            swipe = nil
            tapLocation = nil
        }else if tapLocation != nil{
            delegate?.BlockDidTap(tapLocation!)
            tapLocation = nil
        }
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
        
        tapLocation = nil
        swipe = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}