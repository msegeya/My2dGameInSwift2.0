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

let TickLengthLevelOne = NSTimeInterval(2000)

let sounds: [String: SKAction] = [
"Fall": SKAction.playSoundFileNamed("Fall.wav", waitForCompletion: false),
"HurryUp": SKAction.playSoundFileNamed("hurryUp.wav", waitForCompletion: false),
]

class GameScene: SKScene {
    let darkeningLayer = SKSpriteNode()
    let gameLayer = MainNode()
    let HUDLayer = HUDNode()
    let popUp = PopUpNode()
    
    var columnsNodes = Array<ColumnNode>()
    
    var pauseGame: (() -> ())?
    var resumeGame: (() -> ())?
    
    var tickLengthMillisTmp: Double? = nil
    var tickLengthMillis = TickLengthLevelOne
    var lastTick: NSDate?
    var tick: (() -> ())?
    
    //Init
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
        self.userInteractionEnabled = false
        
        //Background
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        background.anchorPoint = CGPointZero
        addChild(background)
        
        
        //HUD
        HUDLayer.position = CGPoint(x: 33, y: 50)
        HUDLayer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        addChild(HUDLayer)
        HUDLayer.userInteractionEnabled = true
        
        //Main game layer
        gameLayer.position = CGPoint(x: 67, y: 20)
        gameLayer.anchorPoint = CGPointZero
        addChild(gameLayer)
        
        
        //Layer for darkening efect when popUp shows
        darkeningLayer = SKSpriteNode(color: UIColor.blackColor(), size: size)
        darkeningLayer.hidden = true
        darkeningLayer.anchorPoint = CGPointZero
        addChild(darkeningLayer)
        
        
        //Popup
        popUp = PopUpNode(backgroundColor: UIColor.lightGrayColor(), backgroundSize: CGSize(width: 250, height: 170), frameSize: size)
        popUp.zPosition = 100
        popUp.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(popUp)
        popUp.runAction(SKAction.scaleTo(0.0, duration: 0.01))
    }
    override func didMoveToView(view: SKView){
        clear()
    }
    //Init
    
    
    //Clock
    override func update(currentTime: CFTimeInterval) {
        if lastTick == nil {
            return
        }
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        
        //progressBar update
        HUDLayer.wavesLeftNode.setProgress(CGFloat(timePassed) / CGFloat(tickLengthMillis))
        
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
    func playSound(name: String){
        if audio.sounds{
            runAction(sounds[name])
        }
        
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
        
        runAction(SKAction.waitForDuration(0.5), completion: completion)
    }
    func showShortMessage(message: String, delay: NSTimeInterval = 1, completion: ()->()){
        let messageLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        messageLabel.text = message
        messageLabel.fontSize = 34
        messageLabel.fontColor = UIColor.grayColor()
        messageLabel.zPosition = 99
        self.addChild(messageLabel)
        messageLabel.runAction(SKAction.scaleTo(0.0, duration: 0.01))
        messageLabel.alpha = 0
        
        let action = SKAction.scaleTo(1.5, duration: 0.1)
        action.timingMode = .EaseIn
        let action2 = SKAction.scaleTo(1.0, duration: 0.1)
        action2.timingMode = .EaseOut
        
        let action3 = SKAction.fadeInWithDuration(0.15)
        let delay = SKAction.waitForDuration(delay)
        let action4 = SKAction.scaleTo(0.0, duration: 0.1)
        let action5 = SKAction.fadeAlphaTo(0.0, duration: 0.1)
        let action6 = SKAction.removeFromParent()
        
        messageLabel.runAction(SKAction.sequence([SKAction.group([SKAction.sequence([action, action2]),action3]), delay, SKAction.group([action4, action5]), action6]), completion: completion)
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
        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.4)
        fadeOut.timingMode = .EaseOut
        let scale = SKAction.scaleTo(1.2, duration: 0.4)
        scale.timingMode = .EaseOut
        let removeColumnActionGroup = SKAction.group([fadeOut, scale])

        var wholeDelayTime = 0.0
        
        for column in columnsNodes.reverse(){
            if column.children.count > 0{
                
                let duration = wholeDelayTime * 0.3
                let delay = SKAction.waitForDuration(NSTimeInterval(duration))
                println(duration)
                column.runAction(SKAction.sequence([delay, removeColumnActionGroup, SKAction.removeFromParent()]))
                wholeDelayTime++
            }
        }
        columnsNodes.removeAll(keepCapacity: false)
        runAction(SKAction.waitForDuration(NSTimeInterval(wholeDelayTime * 0.4)), completion: completion)
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
                if audio.sounds{
                    acctions.append(sounds["Fall"]!)
                }
                
                let sequence = SKAction.sequence(acctions)
                block.sprite?.runAction(sequence)
            }
        }
        runAction(SKAction.waitForDuration(0.15), completion: completion)
    }
    func animateAddingSpritesForColumn(column: Column, completion: ()->()){
        
        var newColumnNode = ColumnNode()
        newColumnNode.anchorPoint = CGPointZero
        moveCurrentColumns()
        
        for (blockId, block) in enumerate(column.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.anchorPoint = CGPointZero
            sprite.position = pointForColumn(0, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            //sprite.zPosition = CGFloat(blockId)
            
            newColumnNode.addChild(sprite)
            block!.sprite = sprite
            
            //animation
//            sprite.alpha = 0
//            let move = SKAction.moveTo(pointForColumn(0, row: block!.row), duration: 0.15)
//            move.timingMode = .EaseOut
//            let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.15)
//            fadeIn.timingMode = .EaseOut
//            let delay = SKAction.waitForDuration(NSTimeInterval(blockId) * 0.03)
//            sprite.runAction(SKAction.sequence([delay, SKAction.group([move, fadeIn])]))
        }
        
        var tmpColumnArray = columnsNodes
        columnsNodes.removeAll(keepCapacity: false)
        
        columnsNodes.append(newColumnNode)
        for col in tmpColumnArray{
            columnsNodes.append(col)
        }
        newColumnNode.alpha = 0
        newColumnNode.runAction(SKAction.scaleTo(0.0, duration: 0.01))
        gameLayer.columnsLayer.addChild(columnsNodes[0])
        
        let action2 = SKAction.scaleTo(1.1, duration: 0.1)
        action2.timingMode = .EaseIn
        let action3 = SKAction.scaleTo(1.0, duration: 0.07)
        action3.timingMode = .EaseOut
        
        let action4 = SKAction.fadeInWithDuration(0.1)
        
        newColumnNode.runAction(SKAction.group([action4, SKAction.sequence([action2, action3])]))
        
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
                columnsNodes.removeAtIndex(k)
                columnNode.removeFromParent()
                break
            }
            k++
        }
    }
    func animateAddingNextColumnPreview(column: Column){
        gameLayer.nextColumnPreviewNode.removeAllChildren()
        for (blockId, block) in enumerate(column.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = CGPoint(x: 0, y: CGFloat(blockId) * (BlockHeight / 2))
            sprite.size = CGSize(width: CGFloat(BlockWidth / 2), height: CGFloat(BlockHeight / 2))
            sprite.anchorPoint = CGPointZero
            
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
        let newColumnNode = ColumnNode()
        
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

