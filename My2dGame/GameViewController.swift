//
//  GameViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import UIKit
import SpriteKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

let audio = Audio()

enum Direction{
    case Up, Down, Left, Right
}

class GameViewController: UIViewController, GameDelegate, PopUpDelegate, ColumnLayerDelegate{
    
    var gameScene: GameScene!
    var gameLogic: Game!
    var choosenLevel: Level!
    
    var timePassed = 0.0
    var isGamePaused: Bool = true{
        didSet{
            if isGamePaused{
                self.gameScene.HUDLayer.userInteractionEnabled = false
                self.gameScene.gameLayer.userInteractionEnabled = false
                
            }else{
                self.gameScene.gameLayer.userInteractionEnabled = true
            }
        }
    }
    
    var skView: SKView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseGameSceneNotificationReceived:", name:"pauseGameScene", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumeGameSceneNotificationReceived:", name:"resumeGameScene", object: nil)
        
        skView = view as SKView
        skView.multipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        gameLogic = Game(level: choosenLevel)
        
        gameLogic.delegate = self
        
        startGame()
    }
    
    func pauseGameSceneNotificationReceived(notification: NSNotification){
        if isGamePaused{
            return
        }
        gameDidPause()
    }
    func resumeGameSceneNotificationReceived(notification: NSNotification){
        if isGamePaused{
            gameDidResume()
        }
    }
    
    //MenuDelegates
    func startGame() {
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.tick = didTick
        gameScene.tickLengthMillis = TickLengthLevelOne
        
        gameScene.pauseGame = gameDidPause
        gameScene.resumeGame = gameDidResume
        gameScene.popUp.delegate = self
        
        gameScene.gameLayer.delegate = self
        
        skView.presentScene(gameScene)

            audio.reset()
            self.gameLogic.reset()
            self.gameScene.tickLengthMillis = TickLengthLevelOne
            self.updateHUD()
            self.gameLogic.beginGame()
            self.gameScene.HUDLayer.userInteractionEnabled = true
            self.gameScene.gameLayer.userInteractionEnabled = true
            self.gameScene.animateAddingNextColumnPreview(self.gameLogic.nextColumn!)
        
    }
    //MenuDelegates
    
    
    //PopUpDelegates
    func gameDidPause(){
        isGamePaused = true
        
        gameScene.showPopUpAnimation(){
            
        }
        
        if let lastTick = gameScene.lastTick{
            timePassed = lastTick.timeIntervalSinceNow
            gameScene.stopTicking()
        }
    }
    func gameDidResume(){
        if !isGamePaused{
            return
        }
        self.isGamePaused = false
        gameScene.hidePopUpAnimation(){
            self.gameScene.HUDLayer.userInteractionEnabled = true
            let newLastTickValue = NSDate().dateByAddingTimeInterval(NSTimeInterval(self.timePassed))
            self.gameScene.lastTick = newLastTickValue
        }
    }
    func gameDidExitToMenu(){
        audio.backgroundMusicPlayer.volume = 0.0
        navigationController?.popToRootViewControllerAnimated(true)
    }
    //PopUpDelagates
    
    
    //GameDelegates
    func gameDidBegin(game: Game) {
        gameScene.showShortMessage(NSLocalizedString("Start", comment: "Start"), delay: 1){
            self.isGamePaused = false
            self.didTick()
            self.gameScene.startTicking()
        }
    }
    
    func gameDidEnd(game: Game) {
        self.gameScene.stopTicking()
        self.gameScene.animateClearingScene(){}
        gameScene.showShortMessage(NSLocalizedString("GameOver", comment: "Game Over"), delay: 2.0){
            game.beginGame()
            self.updateHUD()
        }
    }
    
    func gameDidLevelUp(game: Game) {
        gameScene.stopTicking()
        isGamePaused = true
        
        if gameScene.tickLengthMillisTmp != nil{
            gameScene.tickLengthMillis = gameScene.tickLengthMillisTmp!
            gameScene.tickLengthMillisTmp = nil
        }
        
        if(gameScene.tickLengthMillis >= 1800){
            gameScene.tickLengthMillis -= 100
        }else if gameScene.tickLengthMillis > 600{
            gameScene.tickLengthMillis -= 50
        }
        let results = game.sumUpPointsInColumns()
        updateHUD("level")
        updateHUD("wavesLeft")
        
        gameScene.showShortMessage(NSLocalizedString("LevelUp", comment: "Level Up"), delay: 1){
            self.gameScene.animateSummaryResults(results){
                game.beginGame()
                self.updateHUD()
                self.isGamePaused = false
                self.gameScene.HUDLayer.userInteractionEnabled = true
            }
        }
    }
    
    func didTick(){
        gameScene.gameLayer.userInteractionEnabled = false
        if let newColumn = gameLogic.newColumn(){
            gameScene.HUDLayer.wavesLeftLabelNode.text = String(format: "%ld", gameLogic.wavesLeft)
            gameScene.animateAddingSpritesForColumn(newColumn){
                self.gameScene.animateAddingNextColumnPreview(self.gameLogic.nextColumn!)
                self.gameScene.gameLayer.userInteractionEnabled = true
            }
        }
        if gameLogic.wavesLeft == 0{
            gameScene.tickLengthMillisTmp = gameScene.tickLengthMillis
            gameScene.tickLengthMillis = 4200
            gameScene.playSound("HurryUp")
            gameScene.showShortMessage(NSLocalizedString("HurryUp", comment: "Hurry Up"), delay: 1, completion: {})
        }
    }
    //GameDelegates
    
    
    //Gestures handling
    func HorizontalSwipeDetected(location: CGPoint, direction: Direction){
        if isGamePaused{
            return
        }
        if let lastTick = gameScene.lastTick{
            let timePassed = lastTick.timeIntervalSinceNow * -1000
            
            var tmp = (gameScene.tickLengthMillis - 150)
            if timePassed >= tmp || timePassed <= 150{
                return
            }
        }
        
        let isEdited = gameLogic.slideColumnsRight()
        
        if isEdited{
            gameScene.animateSlidingColumns(){}
        }
        

    }
    func ColumnDidSwipe(location: CGPoint, direction: Direction){
        if isGamePaused{
            return
        }
        if let lastTick = gameScene.lastTick{
            let timePassed = lastTick.timeIntervalSinceNow * -1000
           
            var tmp = (gameScene.tickLengthMillis - 150)
            if timePassed >= tmp || timePassed <= 150{
                return
            }
        }
        
        let (success, column, row) = convertPoint(location)
        
        if success{
            if let (oldColumn, newColumn) = gameLogic.swipeColumn(column){
                gameScene.animateSwipingColumn(oldColumn, newColumn: newColumn, direction: direction)
                updateHUD("score")
            }
        }
    }
    
    func BlockDidTap(location: CGPoint){
        if isGamePaused{
            return
        }
        
        let (success, column, row) = convertPoint(location)
        
        if success{
            if let (removedBlocks, fallenBlocks) = gameLogic.removeMatchesBlocks(column, row: row){
                if removedBlocks.count > 0{
                    
                    if removedBlocks.count > 5{
                        gameScene.showShortMessage(NSLocalizedString("GoodGod", comment: "Good God"), delay: 0.4, completion: {self.gameLogic.score += 50
                            self.updateHUD("score")})
                        
                    }else if removedBlocks.count == 5{
                        gameScene.showShortMessage(NSLocalizedString("VeryGood", comment: "Very Good"), delay: 0.3, completion: {self.gameLogic.score += 25
                        self.updateHUD("score")})
                        
                    }else if removedBlocks.count == 4{
                        gameScene.showShortMessage(NSLocalizedString("Nice", comment: "Nice"), delay: 0.2, completion: {self.gameLogic.score += 10
                        self.updateHUD("score")})
                        
                    }else{
                        self.updateHUD("score")
                    }
                    gameScene.gameLayer.userInteractionEnabled = false
                    gameScene.animateRemovingBlocksSprites(removedBlocks, fallenBlocks: fallenBlocks){
                        self.gameScene.gameLayer.userInteractionEnabled = true
                    }
                }
            }
        }
    }
    //Gestures handling
    
    
    func updateHUD(){
        self.gameScene.gameLayer.levelLabelNode.text = NSLocalizedString("Level", comment: "Level") + ": \(gameLogic.currentLevel.id)"
        self.gameScene.gameLayer.scoreLabelNode.text = NSLocalizedString("Score", comment: "Score") + ": \(gameLogic.score)"
        self.gameScene.HUDLayer.wavesLeftLabelNode.text = "\(gameLogic.wavesLeft)"
    }
    func updateHUD(label: String){
        switch label{
        case "level":
            self.gameScene.gameLayer.levelLabelNode.text = NSLocalizedString("Level", comment: "Level") + ": \(gameLogic.currentLevel.id)"
            break
            
        case "score":
            self.gameScene.gameLayer.scoreLabelNode.text = NSLocalizedString("Score", comment: "Score") + ": \(gameLogic.score)"
            break
            
        case "wavesLeft":
            self.gameScene.HUDLayer.wavesLeftLabelNode.text = "\(gameLogic.wavesLeft)"
            break
            
        default:
            break
        }
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if (point.x >= 0 && point.x < CGFloat(NumColumns) * (BlockWidth+BlockWidthOffset) &&
            point.y >= 0 && point.y < CGFloat(NumRows) * (BlockHeight+BlockHeightOffset)) {
                return (true, Int(point.x / (BlockWidth+BlockWidthOffset)), Int(point.y / (BlockHeight+BlockHeightOffset)))
        } else {
            return (false, 0, 0)
        }
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillDisappear(true)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
}