//
//  GameScene.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

let BlockWidth: CGFloat = 42.5
let BlockHeight: CGFloat = 42.5

let BlockWidthOffset: CGFloat = 1.5
let BlockHeightOffset: CGFloat = -3.5

let TickLengthLevelOne = NSTimeInterval(2600)

let fallSound = SKAction.playSoundFileNamed("Fall.wav", waitForCompletion: false)

class GameScene: SKScene {
    let darkeningLayer = SKSpriteNode()
    let gameLayer = MainNode()
    let HUDLayer = HUDNode()
    let popUp = PopUpNode()
    
    var columnsNodes = Array<SKNode>()
    var sound: Switch = .On
    
    var pauseGame: (() -> ())?
    var resumeGame: (() -> ())?
    
    var tickLengthMillis = TickLengthLevelOne
    var lastTick: NSDate?
    var tick: (() -> ())?
    
    //Init
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //background
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = self.frame.size
        addChild(background)
        
        
        //HUD
        HUDLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        HUDLayer.position.x += gameLayer.size.width / 2
        HUDLayer.position.y += (gameLayer.size.height / 2) - 65
        gameLayer.addChild(HUDLayer)

        
        //Main game layer
        gameLayer.position = CGPoint(x: -8, y: 27)
        addChild(gameLayer)
        
        
        //Darkening efect when popUp shows
        darkeningLayer = SKSpriteNode(color: UIColor.blackColor(), size: self.frame.size)
        darkeningLayer.hidden = true
        addChild(darkeningLayer)
        
        
        //Popup
        popUp = PopUpNode(backgroundColor: UIColor.lightGrayColor(), backgroundSize: CGSize(width: 250, height: 170))
        popUp.zPosition = 100
        addChild(popUp)
        popUp.runAction(SKAction.scaleTo(0.0, duration: 0.01))
    }
    override func didMoveToView(view: SKView){
        //setup
    }
    //Init
    
    
    //Clock
    override func update(currentTime: CFTimeInterval) {
        if lastTick == nil {
            return
        }
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        
        //progressBar update
        HUDLayer.wavesLeftNode.setProgress(CGFloat(timePassed) / CGFloat(TickLengthLevelOne))
        
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
    //Clock
    
    
    //Other
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        var touch: AnyObject? = touches.anyObject()
        var location = touch?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if popUp.hidden == false{
            resumeGame!()
        }else if touchedNode.name == "menuButton"{
            pauseGame!()
        }
    }
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        if column != 0{
            x = CGFloat(column) * (BlockWidth+BlockWidthOffset)
        }
        if row != 0{
            y = CGFloat(row) * (BlockHeight+BlockHeightOffset)
        }
        
        return CGPoint(x: x, y: y)
    }
    //Other
    
    
    //Animations
    func clear(){
        columnsNodes.removeAll(keepCapacity: false)
        gameLayer.columnsLayer.removeAllChildren()
    }
    func animateClearingScene(completion: ()->()){
        columnsNodes.removeAll(keepCapacity: false)
        gameLayer.columnsLayer.removeAllChildren()
        
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    func showPopUpAnimation(){
        popUp.hidden = false
        darkeningLayer.hidden = false
        darkeningLayer.alpha = 0
        popUp.alpha = 0
        
        let action = SKAction.fadeAlphaTo(0.3, duration: 0.1)
        
        let action2 = SKAction.scaleTo(1.2, duration: 0.2)
        action2.timingMode = .EaseIn
        let action3 = SKAction.scaleTo(1.0, duration: 0.15)
        action3.timingMode = .EaseOut
        
        let action4 = SKAction.fadeInWithDuration(0.1)
        
        darkeningLayer.runAction(SKAction.group([action]))
        popUp.runAction(SKAction.group([action4, SKAction.sequence([action2, action3])]))
    }
    func hidePopUpAnimation(completion: ()->()){
        let action = SKAction.fadeAlphaTo(0.0, duration: 0.1)
        
        let action2 = SKAction.scaleTo(0.0, duration: 0.1)
        
        popUp.runAction(SKAction.group([action, action2]))
        darkeningLayer.runAction(SKAction.group([action]), completion:{
            self.popUp.hidden = true
            self.darkeningLayer.hidden = true
        })
        
        runAction(SKAction.waitForDuration(0.3), completion: completion)
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
            block.sprite?.runAction(sequence)
        }
        
        for column in fallenBlocks{
            for (blockId, block) in enumerate(column){
                let newPosition = pointForColumn(0, row: block.row)
                
                let move = SKAction.moveTo(newPosition, duration: 0.15)
                move.timingMode = SKActionTimingMode.EaseIn
                
                var acctions = Array<SKAction>()
                
                acctions.append(SKAction.waitForDuration(NSTimeInterval(blockId) * 0.03))
                acctions.append(move)
                if sound == .On{
                    acctions.append(fallSound)
                }
                
                let sequence = SKAction.sequence(acctions)
                block.sprite?.runAction(sequence)
            }
        }
        runAction(SKAction.waitForDuration(0.15), completion: completion)
    }
    func animateAddingSpritesForColumn(column: Column, completion: ()->()){
        
        var newColumnNode = SKNode()
        
        moveCurrentColumns()
        
        for (blockId, block) in enumerate(column.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = pointForColumn(-2, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            //sprite.zPosition = CGFloat(blockId)
            
            newColumnNode.addChild(sprite)
            block!.sprite = sprite
            
            //animation
            sprite.alpha = 0
            let move = SKAction.moveTo(pointForColumn(0, row: block!.row), duration: 0.15)
            move.timingMode = .EaseOut
            let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.15)
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
        gameLayer.columnsLayer.addChild(columnsNodes[0])
        
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    func moveCurrentColumns(){
        var k = 0
        for columnNode in columnsNodes{
            if(columnNode.children.count > 0){
                let move = SKAction.moveByX(BlockWidth+BlockWidthOffset, y: 0, duration: 0.1)
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
        gameLayer.nextColumnPreviewNode.removeAllChildren()
        for (blockId, block) in enumerate(column.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = pointForColumn(0, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            
            gameLayer.nextColumnPreviewNode.addChild(sprite)
            block!.sprite = sprite
            
            //animation
            sprite.alpha = 0
            let fadeIn = SKAction.fadeAlphaTo(0.3, duration: 0.2)
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
        
        let move = SKAction.moveByX(0, y: -moveDistance, duration: 0.15)
        move.timingMode = .EaseOut
        let remove = SKAction.removeFromParent()
        
        columnsNodes[column].runAction(SKAction.sequence([move, remove]))
        newColumnNode.runAction(move)
        columnsNodes[column] = newColumnNode
        gameLayer.columnsLayer.addChild(newColumnNode)
    }
    //Animations

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
}

