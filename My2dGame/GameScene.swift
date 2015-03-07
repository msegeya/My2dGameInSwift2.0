//
//  GameScene.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

let BlockWidth: CGFloat = 39.0
let BlockHeight: CGFloat = 33.0

let TickLengthLevelOne = NSTimeInterval(3600)

class GameScene: SKScene {
    let gameLayer = SKNode()
    let blocksLayer = SKNode()
    let bottomNumbersLayer = SKNode()
    let nextColumnPreviewNode = SKNode()
    let HUDLayer = SKNode()
    
    var levelLabelNode = SKLabelNode()
    var scoreLabelNode = SKLabelNode()
    var wavesLeftLabelNode = SKLabelNode()
    
    var popUp = UIView()
    
    var columnsNodes = Array<SKNode>()
    
    var tickLengthMillis = TickLengthLevelOne
    var lastTick: NSDate?
    var tick: (() -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = self.frame.size
        addChild(background)
        
        gameLayer.position = CGPoint(x: -20, y: -4)
        addChild(gameLayer)
        
        bottomNumbersLayer.position = CGPoint(
            x: (-BlockWidth * CGFloat(NumColumns) / 2) + (BlockWidth / 2),
            y: (-BlockHeight * CGFloat(NumRows) / 2) - 15)
        
        for i in 0..<NumColumns{
            let Label = SKLabelNode(fontNamed: "GillSans-Bold")
            Label.fontSize = 12
            Label.fontColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 0.80)
            Label.text = NSString(format: "%ld", i+1)
            Label.position = CGPoint(x: i * Int(BlockWidth), y: 0)
            bottomNumbersLayer.addChild(Label)
        }
        gameLayer.addChild(bottomNumbersLayer)

        blocksLayer.position = CGPoint(
            x: -BlockWidth * CGFloat(NumColumns) / 2,
            y: -BlockHeight * CGFloat(NumRows) / 2)
        
        gameLayer.addChild(blocksLayer)
        
        let nextColumnNodePosition = CGPoint(
            x: (-BlockWidth * CGFloat(NumColumns) / 2) - (1.4 * BlockWidth),
            y: -BlockHeight * CGFloat(NumRows) / 2)
        nextColumnPreviewNode.position = nextColumnNodePosition
        gameLayer.addChild(nextColumnPreviewNode)
        
        let levelNode = SKSpriteNode(imageNamed: "Level")
        levelNode.size = CGSize(width: 50, height: 50)
        
        levelLabelNode = HUDSKLabelNode()
        levelNode.addChild(levelLabelNode)
        
        
        let scoreNode = SKSpriteNode(imageNamed: "Score")
        scoreNode.position.y -= 50
        scoreNode.size = CGSize(width: 50, height: 50)
        
        scoreLabelNode = HUDSKLabelNode()
        scoreNode.addChild(scoreLabelNode)
        
        
        let wavesLeftNode = SKSpriteNode(imageNamed: "WavesLeft")
        wavesLeftNode.position.y -= 100
        wavesLeftNode.size = CGSize(width: 50, height: 50)
        
        wavesLeftLabelNode = HUDSKLabelNode()
        wavesLeftNode.addChild(wavesLeftLabelNode)
        
        
        let menuButtonNode = SKSpriteNode(imageNamed: "Menu")
        menuButtonNode.position.y -= 200
        menuButtonNode.size = CGSize(width: 50, height: 50)
        menuButtonNode.name = "menuButton"
        
        
        HUDLayer.addChild(levelNode)
        HUDLayer.addChild(scoreNode)
        HUDLayer.addChild(wavesLeftNode)
        HUDLayer.addChild(menuButtonNode)
        
        HUDLayer.position = CGPoint(
            x: self.size.width * 0.48,
            y: self.size.height * 0.35)
        
        gameLayer.addChild(HUDLayer)
        
        //runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("BackgroundSound.mp3", waitForCompletion: true)))
    }

    
    override func didMoveToView(view: SKView){
        popUp = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 100))
        popUp.backgroundColor = UIColor.whiteColor()
        popUp.layer.position = self.view!.center
        
        let image = UIImage(named: "name") as UIImage?
        let button   = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRectMake(100, 100, 100, 100)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: "didResume:", forControlEvents:.TouchUpInside)
        
        popUp.addSubview(button)
        self.view?.addSubview(popUp)
        
        popUp.hidden = true
    }
    
    func showPopUp(){
        popUp.hidden = false
        let move = SKAction.moveByX(BlockWidth, y: 0, duration: 0.1)
        move.timingMode = SKActionTimingMode.EaseOut
        
    }
    func hidePopUp(){
        popUp.hidden = true
    }
    
    override func update(currentTime: CFTimeInterval) {
        if lastTick == nil {
            return
        }
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            lastTick = NSDate()
            //tick?() shorthand for statement below:
            if tick != nil {
                tick!()
            }
        }
    }
    func startTicking() {
        lastTick = NSDate()
    }
    func stopTicking() {
        lastTick = nil
    }
    
    func clear(){
        columnsNodes.removeAll(keepCapacity: false)
        blocksLayer.removeAllChildren()
    }
    
    func animateClearingScene(completion: ()->()){
        columnsNodes.removeAll(keepCapacity: false)
        blocksLayer.removeAllChildren()
        
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    

    
    func animateSummaryResults(results: Array<Int>, columns: Array<Column>, completion: ()->()){
        for (columnId, column) in enumerate(columns){
            for (blockId,block) in enumerate(column.blocks){
                if(block != nil){
                    let move = SKAction.moveByX(3, y: 4, duration: 0.2)
                    move.timingMode = .EaseOut
                    let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.2)
                    fadeOut.timingMode = .EaseOut
                    let delay = SKAction.waitForDuration(NSTimeInterval(CGFloat(blockId + columnId) * 0.1))
                    block!.sprite!.runAction(SKAction.sequence([delay, SKAction.group([move, fadeOut]), SKAction.removeFromParent()]))
                }
            }
        }
        
        runAction(SKAction.waitForDuration(1), completion: completion)
    }
    
    func animateRemovingBlocksSprites(blocksToRemove: Array<Block>, fallenBlocks: Array<Array<Block>>, completion: ()->()){
        var acctions = Array<SKAction>()
        
        acctions.append(SKAction.fadeOutWithDuration(0.2))
        acctions.append(SKAction.removeFromParent())
        
        let sequence = SKAction.sequence(acctions)
        
        for (blockId, block) in enumerate(blocksToRemove){
            let Label = SKLabelNode(fontNamed: "GillSans-Bold")
            Label.fontSize = 14
            Label.text = "1"
            Label.position = CGPoint(
                x: block.column.id * Int(BlockWidth) + Int(BlockWidth/2),
                y: block.row * Int(BlockHeight) + Int(BlockHeight/2))
            blocksLayer.addChild(Label)
            Label.alpha = 1
            
            let move = SKAction.moveByX(3, y: 4, duration: 0.3)
            move.timingMode = .EaseOut
            let fadeIn = SKAction.fadeAlphaTo(0, duration: 0.3)
            fadeIn.timingMode = .EaseOut
            let delay = SKAction.waitForDuration(NSTimeInterval(CGFloat(blockId) * 0.1))
            Label.runAction(SKAction.sequence([delay, SKAction.group([move, fadeIn]), SKAction.removeFromParent()]))
            
            
            block.sprite?.runAction(sequence)
        }
        for column in fallenBlocks{
            for (blockId, block) in enumerate(column){
                let newPosition = pointForColumn(0, row: block.row)
                
                let move = SKAction.moveTo(newPosition, duration: 0.2)
                move.timingMode = SKActionTimingMode.EaseIn
                
                var acctions = Array<SKAction>()
                
                acctions.append(SKAction.waitForDuration(NSTimeInterval(blockId) * 0.05))
                acctions.append(move)
                acctions.append(SKAction.playSoundFileNamed("Fall.wav", waitForCompletion: false))
                
                let sequence = SKAction.sequence(acctions)
                block.sprite?.runAction(sequence)
            }
        }
        runAction(SKAction.waitForDuration(0.25), completion: completion)
    }
    
    func animateAddingSpritesForColumn(column: Column, completion: ()->()){
        
        var newColumnNode = SKNode()
        
        moveCurrentColumns()
        
        for (blockId, block) in enumerate(column.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = pointForColumn(-2, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            
            newColumnNode.addChild(sprite)
            block!.sprite = sprite
            
            //animation
            sprite.alpha = 0
            let move = SKAction.moveTo(pointForColumn(0, row: block!.row), duration: 0.2)
            move.timingMode = .EaseOut
            let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.2)
            fadeIn.timingMode = .EaseOut
            let delay = SKAction.waitForDuration(NSTimeInterval(blockId) * 0.03)
            sprite.runAction(SKAction.sequence([delay, SKAction.group([move, fadeIn])]))
        }
        var tmpColumnArray = columnsNodes
        columnsNodes.removeAll(keepCapacity: false)
        
        columnsNodes.append(newColumnNode)
        for col in tmpColumnArray{
            columnsNodes.append(col)
        }
        blocksLayer.addChild(columnsNodes[0])
        
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    func moveCurrentColumns(){
        var k = 0
        for columnNode in columnsNodes{
            if(columnNode.children.count > 0){
                let move = SKAction.moveByX(BlockWidth, y: 0, duration: 0.1)
                move.timingMode = SKActionTimingMode.EaseOut
                columnNode.runAction(move)
            }else{
                columnNode.removeFromParent()
                columnsNodes.removeAtIndex(k)
                break
            }
            k++
        }
        if(columnsNodes.count == NumColumns){
            var tmp = columnsNodes[NumColumns-1]
            tmp.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: BlockWidth, height: BlockHeight))
            tmp.physicsBody?.dynamic = true
            
            tmp.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.removeFromParent()]))
        }
    }
    
    func animateAddingNextColumnPreview(column: Column){
        nextColumnPreviewNode.removeAllChildren()
        for (blockId, block) in enumerate(column.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = pointForColumn(0, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            
            nextColumnPreviewNode.addChild(sprite)
            block!.sprite = sprite
            
            //animation
            sprite.alpha = 0
            let fadeIn = SKAction.fadeAlphaTo(0.2, duration: 0.2)
            fadeIn.timingMode = .EaseOut
            sprite.runAction(fadeIn)
        }
    }
    
    func animateSwipingColumn(column: Int, newColumn: Column, direction: UISwipeGestureRecognizerDirection){
        let oldPosition = columnsNodes[column].position
        let newColumnNode = SKNode()
        
        for (blockId, block) in enumerate(newColumn.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = pointForColumn(0, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            
            newColumnNode.addChild(sprite)
            block!.sprite = sprite
        }
        
        newColumnNode.position = oldPosition
        var moveDistance: CGFloat = 300
        
        if(direction == .Up){
            moveDistance = -moveDistance
        }
        
        newColumnNode.position.y += moveDistance
        
        let move = SKAction.moveByX(0, y: -moveDistance, duration: 0.4)
        move.timingMode = .EaseOut
        let remove = SKAction.removeFromParent()
        
        columnsNodes[column].runAction(SKAction.sequence([move, remove]))
        newColumnNode.runAction(move)
        columnsNodes[column] = newColumnNode
        blocksLayer.addChild(newColumnNode)
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * BlockWidth + BlockWidth / 2,
            y: CGFloat(row) * BlockHeight + BlockHeight / 2)
    }
    
    func playSound(sound:String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
}

