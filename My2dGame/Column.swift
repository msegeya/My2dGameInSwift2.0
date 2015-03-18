//
//  Column.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//
import Darwin

class Column {
    var id: Int
    var blocks: Array<Block?>
    var maxHeight: Int
    var currentHeight: Int
    
    var previouseColumn: Column?
    var nextColumn: Column?
    
    init(height: Int){
        self.id = 0
        self.maxHeight = height
        self.blocks = Array<Block>()
        self.currentHeight = 0
        
        self.generateBlocks()
    }
    
    func getBlock(index: Int) -> Block?{
        if(index < currentHeight){
            return blocks[index]
        }else{
            return nil
        }
    }
    
    func sumUpScore() -> Int{
        return maxHeight - currentHeight
    }
    
    func generateBlocks(){
        for var row = 0; row < maxHeight; ++row {
            
            var blockColor = BlockColor.random()
            let block = Block(column: self, row: row, blockColor: blockColor)
            blocks.append(block)
            
            self.currentHeight++
        }
        
        randomBlockTypeForColumn()
    }
    
    func randomBlockTypeForColumn(){
        var probability = 0.7
        var result = Int(arc4random_uniform(10))

        if result > Int(probability * 10){
            return
        }
        
        let rand = Int(arc4random_uniform(UInt32(currentHeight)))
        let block = getBlock(rand)
        
        var randomBlockTypeRawValue = Int(arc4random_uniform(UInt32(NumBlockTypes-1))+1)
        
        block?.blockType = BlockType(rawValue: randomBlockTypeRawValue)
    }
    
    func isEmpty() -> Bool{
        if(currentHeight <= 0){
            return true
        }else{
            return false
        }
    }
    
    func removeBlock(index: Int){
        if(index < self.maxHeight && index >= 0){
            blocks[index] = nil
            self.currentHeight--
        }
    }
    
    func repositionBlocks() -> Array<Block>{
        var counter = 0
        var fallenBlocks = Array<Block>()
        
        for var row = 0; row < self.blocks.count; ++row {
            var block = blocks[row]
            
            if(block == nil){
                counter++
            }else{
                if(counter != 0){
                    block!.row = (row - counter)
                    blocks[row - counter] = block
                    blocks[row] = nil
                    row = (row - counter)
                    
                    fallenBlocks.append(block!)
                    counter = 0
                }
            }
        }
        return fallenBlocks
    }
}