//
//  Block.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

enum BlockColor: Int {
    case Unknown = 0, Red, Blue, Green, Orange
    
    var spriteName: String {
        let spriteNames = [
            "Red",
            "Blue",
            "Green",
            "Orange"]
        
        return spriteNames[rawValue]
    }
    
    static func random() -> BlockColor {
        return BlockColor(rawValue: Int(arc4random_uniform(4)))!
    }
}
enum BlockType: Int {
    case Normal = 0, Bomb, SlowMotion, Hourglass
    
    var typeName: String {
        let typeNames = [
            "Normal",
            "Bomb",
            "SlowMotion",
            "Hourglass"]
        
        return typeNames[rawValue]
    }
}

class Block {
    let blockType: BlockType!
    let blockColor: BlockColor!
    var sprite: SKSpriteNode?
    let column: Column
    var row: Int
    
    var isChecked: Bool
    
    init(column: Column, row: Int, blockColor: BlockColor) {
        self.row = row
        self.blockColor = blockColor
        self.isChecked = false
        self.column = column
        self.blockType = BlockType.Normal
    }
}
