//
//  BlocksToRemoveDetector.swift
//  My2dGame
//
//  Created by Karol Kedziora on 18.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation

class BlocksToRemoveDetector {
    
    private var blocksToRemove: Set<Block>
    private var columnArray: Array<Column?>
    private var matchColor: BlockColor!
    
    init(){
        self.columnArray = Array<Column?>()
        self.blocksToRemove = Set<Block>()
    }
    
    private func blockAtColumn(column: Int, row: Int) -> Block? {
        if(column >= 0 && row >= 0 && column < columnArray.count && row < NumRows){
            if columnArray[column] != nil{
                return columnArray[column]!.getBlock(row)
            }
            return nil
        }else{
            return nil
        }
    }
    
    func getMatchesBlocks() -> Set<Block>?{
        if blocksToRemove.count > 1{
            return blocksToRemove
        }
        return nil
    }
    
    func detectMatchesBlocks(column: Int, row: Int, array: Array<Column?>){
        self.blocksToRemove = Set<Block>()
        self.columnArray = array
        
        if let startBlock = blockAtColumn(column, row: row){
            self.matchColor = startBlock.blockColor
            
            recursion(startBlock, column: column)
            
            if blocksToRemove.count == 1{
                blocksToRemove.removeElement(startBlock)
            }
        }
    }
    
    private func recursion(block: Block?, column: Int){
        if block == nil{
            return
        }
        
        if blocksToRemove.containsElement(block!){
            return
        }
        
        if block!.blockColor == matchColor{
            blocksToRemove.addElement(block!)
            block!.isChecked = true
        }else{
            return
        }
        
        if let tmpBlock = blockAtColumn(column + 1, row: block!.row){
            recursion(tmpBlock, column: column + 1)
        }
        if let tmpBlock = blockAtColumn(column - 1, row: block!.row){
            recursion(tmpBlock, column: column - 1)
        }
        if let tmpBlock = blockAtColumn(column, row: block!.row + 1){
            recursion(tmpBlock, column: column)
        }
        if let tmpBlock = blockAtColumn(column, row: block!.row - 1){
            recursion(tmpBlock, column: column)
        }
        
        return
    }
    
    func detectSpecialBlockTypes(){
        for block in blocksToRemove{
            if block.blockType == BlockType.Bomb{
                block.isChecked = true
                bombDetected(block)
            }
            if block.blockType == BlockType.SlowMotion{
                block.isChecked = true
                laserDetected(block)
            }
        }
    }
    
    private func bombDetected(block: Block){
        for column in -1...1{
            for row in -1...1{
                if let tmpBlock = blockAtColumn(block.column.id+column, row: block.row+row){
                    if !tmpBlock.isChecked{
                        blocksToRemove.addElement(tmpBlock)
                        
                        //detecting bombs in previouse bomb area
                        if tmpBlock.blockType == BlockType.Bomb{
                            tmpBlock.isChecked = true
                            bombDetected(tmpBlock)
                        }
                    }
                }
            }
        }
        return
    }
    
    private func laserDetected(block: Block){
        for column in columnArray{
            if column != nil{
                if let tmpBlock = blockAtColumn(column!.id, row: block.row){
                    if !tmpBlock.isChecked{
                        blocksToRemove.addElement(tmpBlock)
                    }
                }
            }
        }
    }
}
