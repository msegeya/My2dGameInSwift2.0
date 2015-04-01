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

var columnArray: Array<Column?> = Array<Column?>(count: NumColumns, repeatedValue: nil)

class Game {
    
    var level: Int
    var score: Int
    var wavesLeft: Int
    
    var nextColumn: Column?
    var currentNumberOfColumns: Int
    var blocksToRemove: Array<Block>
    var delegate: GameDelegate?
    var detector: BlocksToRemoveDetector
    
    init(){
        level = 1
        score = 0
        wavesLeft = StartingNumWaves
        
        nextColumn = nil
        currentNumberOfColumns = 0
        blocksToRemove = Array<Block>()
        detector = BlocksToRemoveDetector()
    }
    func reset(){
        level = 1
        score = 0
        wavesLeft = StartingNumWaves
        
        nextColumn = nil
        currentNumberOfColumns = 0
        columnArray = Array<Column?>(count: NumColumns, repeatedValue: nil)
        blocksToRemove = Array<Block>()
    }
    
    func beginGame(){
        if(nextColumn == nil){
            nextColumn = Column(height: NumRows)
        }
        
        currentNumberOfColumns = 0
        columnArray = Array<Column?>(count: NumColumns, repeatedValue: nil)
        
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
    
    func swipeColumn(columnId: Int) -> (Column, Column)?{
        if columnArray[columnId] != nil{
            score -= columnArray[columnId]!.currentHeight * (PointsPerBlock / 2)
            let newColumn = Column(height: columnArray[columnId]!.currentHeight)
            let oldColumn = columnArray[columnId]
            newColumn.id = columnId
            columnArray[columnId] = newColumn
            
            return (oldColumn!, newColumn)
        }
        
        return nil
    }
    
    func slideColumnsRight() -> Bool{
        var counter = 0
        var isEdited = false
        
        println("lastcol: \(currentNumberOfColumns-1)")
        for (id, col) in enumerate(columnArray){
            if col != nil{
                println("\(id) - \(col!.id)")
            }else{
                println("\(id) - nil")
            }
            
            
        }
        println("---------------")
        for var col = currentNumberOfColumns-1; col >= 0; --col {
            if let column = columnArray[col]{
                if(counter != 0){
                    columnArray[col]!.id = col + counter
                    columnArray[col + counter] = column
                    columnArray[col] = nil
                    col = col + counter
                    
                    counter = 0
                    if !isEdited{
                        isEdited = true
                    }
                }
            }else{
               counter++
            }
        }
    
        for (id, col) in enumerate(columnArray){
            if col != nil{
                println("\(id) - \(col!.id)")
            }else{
                println("\(id) - nil")
            }
        }
        
        return isEdited
    }
    
    func sumUpPointsInColumns() -> Array<Int>{
        var pointsInColumns = Array<Int>(count: NumColumns, repeatedValue: PointsPerBlock * NumRows)
        
        for (i, column) in enumerate(columnArray){
            if column != nil{
                let columnScore = column!.sumUpScore() * PointsPerBlock
                pointsInColumns.insert(columnScore, atIndex: i)
            }
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
        
        println(columnArray.count)
        var tmpColumnArray = columnArray
        for var i = 0; i < columnArray.count; ++i{
            columnArray[i] = nil
        }
        var flag = false
        var k = 0
        columnArray.insert(nextColumn, atIndex: 0)
        
        for col in tmpColumnArray{
            if(col != nil || flag == true){
                k++
                if k == NumColumns-1{
                    break
                }
                col?.id = k
                columnArray[k] = col
            }else{
                flag = true
            }
        }
        currentNumberOfColumns = k+1
        println(columnArray.count)
        wavesLeft -= 1
        
//        if currentNumberOfColumns > NumColumns{
//            endGame()
//            return nil
//        }
        
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
        //for (id,x) in enumerate(columnArray){
          //  println("   *col\(id)(\(x.id)) - \(x.currentHeight)")
        //}
        //println()
        detector.detectMatchesBlocks(column, row: row, array: columnArray)
        detector.detectSpecialBlockTypes()
        
        //println("matechesBlocks: - \(detector.getMatchesBlocks()?.count)")
        //println()
        if let matchesBlocks = detector.getMatchesBlocks(){
            score += matchesBlocks.count
            
            for block in matchesBlocks{
                block.column.removeBlock(block.row)
            }
            
            var fallenBlocks = Array<Array<Block>>()
            for (id, column) in enumerate(columnArray){
                if column != nil{
                    if column!.currentHeight == 0{
                        columnArray[id] = nil
                    }else{
                        fallenBlocks.append(column!.repositionBlocks())
                    }
                }
            }
            
            println("\(currentNumberOfColumns)")
            return (matchesBlocks, fallenBlocks)
        }
        return nil
    }
    
}