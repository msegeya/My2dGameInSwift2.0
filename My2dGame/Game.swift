//
//  Game.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

let NumColumns = 11
let NumRows = 7

let StartingNumWaves = 12

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
    var detector: BlocksToRemoveDetector
    
    init(){
        level = 1
        score = 0
        wavesLeft = StartingNumWaves
        
        nextColumn = nil
        currentNumberOfColumns = 0
        columnArray = Array<Column>()
        blocksToRemove = Array<Block>()
        detector = BlocksToRemoveDetector()
    }
    func reset(){
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
        }
        for col in pointsInColumns{
            score += col
        }
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
        
        if currentNumberOfColumns > NumColumns{
            endGame()
            return nil
        }
        
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
    
    func removeMatchesBlocks(column: Int, row: Int) -> (removedBlocks: Set<Block>, fallenBlocks: Array<Array<Block>>)?{
        detector.detectMatchesBlocks(column, row: row, array: columnArray)
        println("*1*\(detector.getMatchesBlocks()?.count)")
        detector.detectSpecialBlockTypes()
        println("*2*\(detector.getMatchesBlocks()?.count)")
        
        if let matchesBlocks = detector.getMatchesBlocks(){
            score += matchesBlocks.count
            
            for block in matchesBlocks{
                block.column.removeBlock(block.row)
            }
            
            var fallenBlocks = Array<Array<Block>>()
            for column in columnArray{
                fallenBlocks.append(column.repositionBlocks())
            }
            return (matchesBlocks, fallenBlocks)
        }
        return nil
    }
    
}