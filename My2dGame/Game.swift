//
//  Game.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

let NumColumns = 12
let NumRows = 8

let StartingNumWaves = 13

let PointsPerBlock = 10

protocol GameDelegate {
    
    func gameDidEnd(game: Game)
    func gameDidBegin(game: Game)
    func gameDidLevelUp(game: Game)
}

class Game {
    
    var level: Int
    var score: Int
    var wavesLeft: Int
    
    var nextColumn: Column?
    var currentNumberOfColumns: Int
    var columnArray: Array<Column>
    var blocksToRemove: Array<Block>
    var delegate: GameDelegate?
    
    init(){
        level = 1
        score = 0
        wavesLeft = StartingNumWaves
        
        nextColumn = nil
        currentNumberOfColumns = 0
        columnArray = Array<Column>()
        blocksToRemove = Array<Block>()
    }
    
    func beginGame(){
        if(nextColumn == nil){
            nextColumn = Column(height: NumRows)
        }
        currentNumberOfColumns = 0
        columnArray.removeAll(keepCapacity: false)
        
        delegate?.gameDidBegin(self)
    }
    
    func endGame(){
        level = 1
        score = 0
        wavesLeft = StartingNumWaves
        
        delegate?.gameDidEnd(self)
    }
    
    func levelUp(){
        wavesLeft = StartingNumWaves + level
        level += 1
        
        delegate?.gameDidLevelUp(self)
    }
    
    func swipeColumn(columnId: Int) -> Column?{
        if columnId < columnArray.count{
            score -= columnArray[columnId].currentHeight * (PointsPerBlock / 2)
            let newColumn = Column(height: columnArray[columnId].currentHeight)
            columnArray[columnId] = newColumn
            
            return newColumn
        }
        
        return nil
    }
    
    func sumUpPointsInColumns() -> Array<Int>{
        var pointsInColumns = Array<Int>(count: NumColumns, repeatedValue: PointsPerBlock * NumRows)
        
        for (i, column) in enumerate(columnArray){
            let columnScore = column.sumUpScore() * PointsPerBlock
            pointsInColumns.insert(columnScore, atIndex: i)
            score += columnScore
        }
        pointsInColumns.reverse()
        return pointsInColumns
    }
    
    func newColumn() -> Column?{
        if let result = checkGameState(){
            if(result){
                levelUp()
                return nil
            }else{
                endGame()
                return nil
            }
        }
        
        var tmpColumnArray = columnArray
        columnArray.removeAll(keepCapacity: false)
        
        var flag = false
        var k = 0
        columnArray.append(nextColumn!)
        
        for col in tmpColumnArray{
            if(!col.isEmpty() || flag == true){
                k++
                col.id = k
                columnArray.append(col)
            }else{
                flag = true
            }
        }
        
        wavesLeft -= 1
        currentNumberOfColumns = columnArray.count
        
        var tmpColumn = nextColumn
        nextColumn = Column(height: NumRows)
        
        return tmpColumn
    }
    
    func checkGameState() -> Bool?{
        if(currentNumberOfColumns > NumColumns){
            return false
        }else{
            if(wavesLeft == 0){
                if(currentNumberOfColumns <= NumColumns){
                    return true
                }
            }
        }
        return nil
    }
    
    func blockAtColumn(column: Int, row: Int) -> Block? {
        if(column >= 0 && row >= 0 && column < columnArray.count && row < NumRows){
            return columnArray[column].getBlock(row)
        }else{
            return nil
        }
    }
    
    func removeBlocks(column: Int, row: Int) -> (blocksRemoved: Array<Block>, fallenBlocks: Array<Array<Block>>){
        blocksToRemove.removeAll(keepCapacity: false)
        var fallenBlocks: Array<Array<Block>> = Array<Array<Block>>()
        var removedBlocks: Array<Block> = Array<Block>()
        
        if let block = blockAtColumn(column, row: row){
            findBlocksToRemove(block, column: column)
            
            if(blocksToRemove.count > 0){
                blocksToRemove.append(block)
                for block in blocksToRemove{
                    removedBlocks.append(block)
                    block.column.removeBlock(block.row)
                    score += 1
                }
                for column in columnArray{
                    let result = column.repositionBlocks()
                    fallenBlocks.append(result)
                }
            }else{
                block.isChecked = false
            }
            return (removedBlocks, fallenBlocks: fallenBlocks)
        }
        return (removedBlocks, fallenBlocks: fallenBlocks)
    }
    
    func findBlocksToRemove(block: Block, column: Int){
        if(!block.isChecked){
            block.isChecked = true
            
            if let tmpBlock = blockAtColumn(column + 1, row: block.row){
                if(tmpBlock.blockColor == block.blockColor && !tmpBlock.isChecked){
                    blocksToRemove.append(tmpBlock)
                    findBlocksToRemove(tmpBlock, column: column + 1)
                }
            }
            
            if let tmpBlock = blockAtColumn(column - 1, row: block.row){
                if(tmpBlock.blockColor == block.blockColor && !tmpBlock.isChecked){
                    blocksToRemove.append(tmpBlock)
                    findBlocksToRemove(tmpBlock, column: column - 1)
                }
            }
            
            if let tmpBlock = blockAtColumn(column, row: block.row - 1){
                if(tmpBlock.blockColor == block.blockColor && !tmpBlock.isChecked){
                    blocksToRemove.append(tmpBlock)
                    findBlocksToRemove(tmpBlock, column: column)
                }
            }
            
            if let tmpBlock = blockAtColumn(column, row: block.row + 1){
                if(tmpBlock.blockColor == block.blockColor && !tmpBlock.isChecked){
                    blocksToRemove.append(tmpBlock)
                    findBlocksToRemove(tmpBlock, column: column)
                }
            }
        }
        return
    }
}