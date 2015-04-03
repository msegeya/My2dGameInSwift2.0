//
//  GameScene.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import SpriteKit

let BlockWidth: CGFloat = 42.0
let BlockHeight: CGFloat = 42.0

let BlockWidthOffset: CGFloat = -0.3
let BlockHeightOffset: CGFloat = -0.3

let TickLengthLevelOne = NSTimeInterval(3600)

let sounds: [String: SKAction] = [
    "Fall": SKAction.playSoundFileNamed("Fall.wav", waitForCompletion: false),
    "HurryUp": SKAction.playSoundFileNamed("hurryUp.wav", waitForCompletion: false),
]

class GameScene: SKScene {
    let darkeningLayer = SKSpriteNode()
    let gameLayer = MainNode()
    let HUDLayer = HUDNode()
    let popUp = PopUpNode()
    
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
        HUDLayer.position = CGPoint(x: 33, y: size.height)
        HUDLayer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        addChild(HUDLayer)
        //HUDLayer.userInteractionEnabled = true
        
        
        //Main game layer
        gameLayer.position = CGPoint(x: 74, y: 18)
        gameLayer.anchorPoint = CGPointZero
        addChild(gameLayer)
        
        
        //Layer for darkening efect when popUp shows
        darkeningLayer = SKSpriteNode(color: UIColor.blackColor(), size: size)
        darkeningLayer.hidden = true
        darkeningLayer.anchorPoint = CGPointZero
        addChild(darkeningLayer)
        
        
        //Popup
        popUp = PopUpNode(imageNamed: "PopUpBackground", backgroundSize: CGSize(width: 185, height: 100), frameSize: size)
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
    //    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    //        super.touchesBegan(touches, withEvent: event)
    //
    //        var touch: AnyObject? = touches.anyObject()
    //        var location = touch?.locationInNode(self)
    //        let touchedNode = self.nodeAtPoint(location!)
    //
    ////        println(popUp.hidden)
    ////        if popUp.hidden == false{
    ////            resumeGame!()
    ////        }
    //    }
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
        gameLayer.columnsLayer.removeAllChildren()
    }
    func animateClearingScene(completion: ()->()){
        gameLayer.columnsLayer.removeAllChildren()
        
        runAction(SKAction.waitForDuration(0.5), completion: completion)
    }
    var messageLabel: SKLabelNode = SKLabelNode()
    func showShortMessage(message: String, delay: NSTimeInterval = 1, completion: ()->()){
        messageLabel.runAction(SKAction.fadeOutWithDuration(0.1))
        
        messageLabel = SKLabelNode(fontNamed: "Gill Sans Bold")
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        messageLabel.text = message
        messageLabel.fontSize = 30
        messageLabel.fontColor = UIColor.whiteColor()
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
    func showPopUpAnimation(completion: ()->()){
        popUp.hidden = false
        darkeningLayer.hidden = false
        darkeningLayer.alpha = 0
        darkeningLayer.zPosition = 99
        popUp.alpha = 0
        
        let action = SKAction.fadeAlphaTo(0.6, duration: 0.1)
        let action2 = SKAction.scaleTo(1.2, duration: 0.2)
        action2.timingMode = .EaseIn
        let action3 = SKAction.scaleTo(1.0, duration: 0.15)
        action3.timingMode = .EaseOut
        
        let action4 = SKAction.fadeInWithDuration(0.1)
        
        darkeningLayer.runAction(SKAction.group([action]))
        popUp.runAction(SKAction.group([action4, SKAction.sequence([action2, action3])]), completion: completion)
    }
    func hidePopUpAnimation(completion: ()->()){
        let action = SKAction.fadeAlphaTo(0.0, duration: 0.2)
        let action2 = SKAction.scaleTo(0.0, duration: 0.2)
        
        popUp.runAction(SKAction.group([action, action2]))
        darkeningLayer.runAction(action, completion:{
            self.popUp.hidden = true
            self.darkeningLayer.hidden = true
            self.darkeningLayer.zPosition = 0
        })
        
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    func animateSlidingColumns(completion: ()->()){
        for column in columnArray{
            if column != nil{
                let slide = SKAction.moveToX(pointForColumn(column!.id, row: 0).x, duration: 0.2)
                slide.timingMode = SKActionTimingMode.EaseOut
                slide.speed = 2.0
                column!.spriteNode!.runAction(slide, completion: completion)
            }
        }
    }
    func animateSummaryResults(results: Array<Int>, completion: ()->()){
        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.4)
        fadeOut.timingMode = .EaseOut
        let scale = SKAction.scaleTo(1.2, duration: 0.4)
        scale.timingMode = .EaseOut
        let removeColumnActionGroup = SKAction.group([fadeOut, scale])
        
        var wholeDelayTime = 0.0
        
        for column in columnArray.reverse(){
            if column != nil{
                
                let duration = wholeDelayTime * 0.3
                let delay = SKAction.waitForDuration(NSTimeInterval(duration))
                
                column!.spriteNode!.runAction(SKAction.sequence([delay, removeColumnActionGroup, SKAction.removeFromParent()]))
                wholeDelayTime++
            }
        }
        
        runAction(SKAction.waitForDuration(NSTimeInterval(wholeDelayTime * 0.4)), completion: completion)
    }
    func animateRemovingBlocksSprites(blocksToRemove: Set<Block>, fallenBlocks: Array<Array<Block>>, completion: ()->()){
        var acctions = Array<SKAction>()
        acctions.append(SKAction.fadeOutWithDuration(0.1))
        acctions.append(SKAction.removeFromParent())
        let sequence = SKAction.sequence(acctions)
        
        for (blockId, block) in enumerate(blocksToRemove){
            var emitter = SKEmitterNode(fileNamed: "Crush.sks")
            emitter.particleColorSequence = nil;
            emitter.particleColorBlendFactor = 1.0;
            
            switch block.blockColor!.spriteName{
            case "Blue":
                emitter.particleColor = UIColor(red: 83/255, green: 132/255, blue: 236/255, alpha: 1.0)
                emitter.name = "blue"
                break
            case "Green":
                emitter.particleColor = UIColor(red: 99/255, green: 225/255, blue: 86/255, alpha: 1.0)
                emitter.name = "green"
                break
            case "Orange":
                emitter.particleColor = UIColor(red: 241/255, green: 138/255, blue: 60/255, alpha: 1.0)
                emitter.name = "orange"
                break
            case "Red":
                emitter.particleColor = UIColor(red: 205/255, green: 64/255, blue: 65/255, alpha: 1.0)
                emitter.name = "red"
                break
            default:
                break
            }
            
            var pos = pointForColumn(block.column.id, row: block.row)
            pos.x += BlockWidth/2
            pos.y += BlockHeight/2
            emitter.position = pos
            
            gameLayer.columnsLayer.addChild(emitter)
            
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
                
                let sequence = SKAction.sequence(acctions)
                block.sprite?.runAction(sequence)
            }
            playSound("Fall")
        }
        runAction(SKAction.waitForDuration(0.15), completion: completion)
    }
    func animateAddingSpritesForColumn(column: Column, completion: ()->()){
        
        var newColumnNode = ColumnNode()
        newColumnNode.anchorPoint = CGPointZero
        columnArray[0]!.spriteNode = newColumnNode
        
        moveCurrentColumns(){
            for (blockId, block) in enumerate(column.blocks) {
                let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
                sprite.anchorPoint = CGPointZero
                sprite.position = self.pointForColumn(0, row: block!.row)
                sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
                
                if block!.blockType != BlockType.Normal{
                    let type = SKSpriteNode(imageNamed: block!.blockType.typeName)
                    type.position = CGPoint(x: BlockWidth/2, y: BlockHeight/2)
                    
                    sprite.addChild(type)
                }
                
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
            
            newColumnNode.alpha = 0
            newColumnNode.runAction(SKAction.scaleTo(0.0, duration: 0.01))
            self.gameLayer.columnsLayer.addChild(newColumnNode)
            
            let action2 = SKAction.scaleTo(1.1, duration: 0.1)
            action2.timingMode = .EaseIn
            let action3 = SKAction.scaleTo(1.0, duration: 0.07)
            action3.timingMode = .EaseOut
            
            let action4 = SKAction.fadeInWithDuration(0.1)
            
            newColumnNode.runAction(SKAction.group([action4, SKAction.sequence([action2, action3])]))
        }
        self.runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    func moveCurrentColumns(completion: ()->()){
        for column in columnArray{
            if column != nil{
                let slide = SKAction.moveToX(pointForColumn(column!.id, row: 0).x, duration: 0.2)
                slide.timingMode = SKActionTimingMode.EaseOut
                slide.speed = 2.0
                
                column!.spriteNode!.runAction(slide)
            }
        }
        runAction(SKAction.waitForDuration(0.1), completion: completion)
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
            let fadeIn = SKAction.fadeAlphaTo(0.5, duration: 0.2)
            fadeIn.timingMode = .EaseOut
            sprite.runAction(fadeIn)
        }
    }
    func animateSwipingColumn(oldColumn: Column, newColumn: Column, direction: Direction){
        let oldPosition = oldColumn.spriteNode!.position
        let newColumnNode = ColumnNode()
        newColumnNode.anchorPoint = CGPointZero
        
        for (blockId, block) in enumerate(newColumn.blocks) {
            let sprite = SKSpriteNode(imageNamed: block!.blockColor.spriteName)
            sprite.position = pointForColumn(0, row: block!.row)
            sprite.size = CGSize(width: CGFloat(BlockWidth), height: CGFloat(BlockHeight))
            sprite.anchorPoint = CGPointZero
            
            if block!.blockType != BlockType.Normal{
                let type = SKSpriteNode(imageNamed: block!.blockType.typeName)
                type.position = CGPoint(x: BlockWidth/2, y: BlockHeight/2)
                
                sprite.addChild(type)
            }
            
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
        
        oldColumn.spriteNode!.runAction(SKAction.sequence([move, remove]))
        newColumnNode.runAction(move)
        newColumn.spriteNode = newColumnNode
        gameLayer.columnsLayer.addChild(newColumnNode)
    }
    //Animations
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
}

