//
//  SKProgressBarnode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 08.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

class ProgressBarNode: SKSpriteNode {

    let backgroundImage = SKSpriteNode()
    let shapeToMask = SKSpriteNode()
    let mask = SKShapeNode()
    let cropNode = SKCropNode()
    let radius: CGFloat = 0.0
    
    override init() {
        super.init()
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    init(imageNamed: String){
        super.init()
        
        backgroundImage = SKSpriteNode(imageNamed: imageNamed)
        backgroundImage.size = CGSize(width: 50, height: 50)
        addChild(backgroundImage)
        
        self.shapeToMask = SKSpriteNode(color: UIColor(red:0.780392, green:0.243137, blue:0.219608, alpha:1.0), size: CGSize(width: 47, height: 47))
        self.shapeToMask.alpha = 1
        self.shapeToMask.position.x -= 0.9
        self.shapeToMask.position.y += 1.3
        
        self.mask = SKShapeNode()
        self.mask.antialiased = false
        self.mask.lineWidth = CGFloat(shapeToMask.size.width)
        
        self.radius = shapeToMask.size.width / 2

        cropNode.addChild(shapeToMask)
        cropNode.maskNode = mask
        self.addChild(cropNode)
    }
    init(shapeColorToMask: UIColor, shapeSize: CGSize){
        super.init()
        self.shapeToMask = SKSpriteNode(color: shapeColorToMask, size: shapeSize)
        self.mask = SKShapeNode()
        self.mask.antialiased = false
        self.mask.lineWidth = CGFloat(shapeToMask.size.width)

        self.radius = shapeToMask.size.width / 2
        
        cropNode.addChild(shapeToMask)
        cropNode.maskNode = mask
        self.addChild(cropNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(progress: CGFloat){
        let progress2 = 1.0 - progress;
    
        let startAngle = CGFloat(M_PI) / 2.0;
        let endAngle = startAngle + (progress * 2.0 * CGFloat(M_PI))
    
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPointZero, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    
        self.mask.path = path.CGPath
    }
}