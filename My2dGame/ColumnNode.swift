//
//  ColumnNode.swift
//  My2dGame
//
//  Created by Karol Kedziora on 13.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit


//observer pattern to implementation in the future


class ColumnNode: SKSpriteNode {

    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}