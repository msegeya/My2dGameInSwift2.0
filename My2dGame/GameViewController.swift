//
//  GameViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import UIKit
import SpriteKit

protocol MenuDelegate {
    func startGame()
    func showHighscore()
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

let audio = Audio()


class GameViewController: UIViewController, GameDelegate, PopUpDelegate, MenuDelegate {
    
    var gameCenter: GameCenter!
    
    var gameScene: GameScene!
    var menuScene: MenuScene!
    var gameLogic: Game!
    
    var timePassed = 0.0
    var isGamePaused: Bool = true
    
    var skView: SKView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseGameSceneNotificationReceived:", name:"pauseGameScene", object: nil)
        
        skView = view as SKView
        skView.multipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.ignoresSiblingOrder = true
        
        menuScene = MenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .AspectFill
        menuScene.thisDelegate = self
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        
        gameLogic = Game()
        gameLogic.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        skView.addGestureRecognizer(tapGesture)
        
        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: Selector("handleColumnSwipe:"))
        swipeGestureUp.direction = .Up
        skView.addGestureRecognizer(swipeGestureUp)
        
        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: Selector("handleColumnSwipe:"))
        swipeGestureDown.direction = .Down
        skView.addGestureRecognizer(swipeGestureDown)
        
        skView.presentScene(menuScene)
        
        //self.gameCenter = GameCenter(rootViewController: self)
        
//        /* Open Windows Game Center if player not login in Game Center */
//        self.gameCenter.loginToGameCenter() {
//            (result: Bool) in
//            if result {
//                /* Player is login in Game Center OR Open Windows for login in Game Center */
//            } else {
//                /* Player is not login in Game Center */
//            }
//        }
    }
    
    func pauseGameSceneNotificationReceived(notification: NSNotification){
        if isGamePaused{
            return
        }
        
        gameDidPause()
    }
    
    //MenuDelegates
    func startGame() {
        let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5)
        
        self.gameScene.tickLengthMillis = TickLengthLevelOne
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.tick = didTick
        
        gameScene.pauseGame = gameDidPause
        gameScene.resumeGame = gameDidResume
        gameScene.popUp.delegate = self
        
        skView.presentScene(gameScene, transition: transition)
        
        delay(0.6){
            audio.reset()
            self.gameLogic.reset()
            self.updateHUD()
            self.gameLogic.beginGame()
        }
    }
    func showHighscore() {
        //show highscore scene
    }
    //MenuDelegates
    
    
    //PopUpDelegates
    func gameDidPause(){
        isGamePaused = true
        gameScene.showPopUpAnimation()
        
        if let lastTick = gameScene.lastTick{
            timePassed = lastTick.timeIntervalSinceNow
            gameScene.stopTicking()
        }
    }
    func gameDidResume(){
        gameScene.hidePopUpAnimation(){
            let newLastTickValue = NSDate().dateByAddingTimeInterval(NSTimeInterval(self.timePassed))
            self.gameScene.lastTick = newLastTickValue
            self.isGamePaused = false
        }
    }
    func gameDidExitToMenu(){
        audio.backgroundMusicPlayer.volume = 0.0
        let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5)
        skView.presentScene(menuScene, transition: transition)
    }
    //PopUpDelagates
    
    
    //GameDelegates
    func gameDidBegin(game: Game) {
        gameScene.showShortMessage("Ready.. set.. go!", delay: 1){
            self.isGamePaused = false
            self.view.userInteractionEnabled = true
            self.gameScene.startTicking()
        }
    }
    
    func gameDidEnd(game: Game) {
        view.userInteractionEnabled = false
        self.gameScene.stopTicking()
        self.gameScene.animateClearingScene(){}
        gameScene.showShortMessage("Game Over!", delay: 2.0){
            game.beginGame()
            self.updateHUD()
        }
    }
    
    func gameDidLevelUp(game: Game) {
        view.userInteractionEnabled = false
        gameScene.stopTicking()
        
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
        updateHUD()
        
        gameScene.showShortMessage("Level Up!", delay: 1){
            self.gameScene.animateSummaryResults(results, columns: game.columnArray){
                game.beginGame()
                self.updateHUD()
            }
        }
    }
    
    func didTick(){
        gameScene.gameLayer.columnsLayer.userInteractionEnabled = false
        
        if let newColumn = gameLogic.newColumn(){
            gameScene.HUDLayer.wavesLeftLabelNode.text = String(format: "%ld", gameLogic.wavesLeft)
            gameScene.animateAddingSpritesForColumn(newColumn){
                self.gameScene.gameLayer.columnsLayer.userInteractionEnabled = true
                self.gameScene.animateAddingNextColumnPreview(self.gameLogic.nextColumn!)
            }
        }
        if gameLogic.wavesLeft == 0{
            gameScene.tickLengthMillisTmp = gameScene.tickLengthMillis
            gameScene.tickLengthMillis = 4200
            gameScene.playSound("HurryUp")
            gameScene.showShortMessage("Hurry up!", delay: 1, completion: {})
        }
    }
    //GameDelegates
    
    
    //Gestures handling
    @IBAction func handleColumnSwipe(sender: UISwipeGestureRecognizer) {
        if isGamePaused{
            return
        }
        
        let currentPoint = sender.locationInView(sender.view)
        
        var tmpPoint = currentPoint
        tmpPoint.x -= 36
        tmpPoint.y = 0
        
        let (success, column, row) = convertPoint(tmpPoint)
        if success {
            if let newColumn = gameLogic.swipeColumn(column){
                gameScene.animateSwipingColumn(column, newColumn: newColumn, direction: sender.direction)
                gameScene.HUDLayer.scoreLabelNode.text = "\(gameLogic.score)"
            }
        }
    }
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        if isGamePaused{
            return
        }
        var currentPoint = sender.locationInView(self.view)
        
        currentPoint.x -= 22
        currentPoint.y -= 34
        if currentPoint.y-269 < 0{
            currentPoint.y = abs(currentPoint.y-269)
        }else{
            currentPoint.y = -(currentPoint.y-269)
        }
        println(currentPoint)
        let (success, column, row) = convertPoint(currentPoint)
        if success {
            //println("sukces \(column), \(row)")
            view.userInteractionEnabled = false
            
            let removedBlocks = gameLogic.removeBlocks(column, row: row)
            
            if removedBlocks.blocksRemoved.count > 0{
                
                if removedBlocks.blocksRemoved.count > 5{
                    gameScene.showShortMessage("GOOD GOD!", delay: 0.4, completion: {})
                }else if removedBlocks.blocksRemoved.count == 5{
                    gameScene.showShortMessage("Vvveerryy Gooodd!", delay: 0.3, completion: {})
                }else if removedBlocks.blocksRemoved.count == 4{
                    gameScene.showShortMessage("Nice!", delay: 0.2, completion: {})
                }
                
                gameScene.HUDLayer.scoreLabelNode.text = String(gameLogic.score)
                gameScene.animateRemovingBlocksSprites(removedBlocks.blocksRemoved, fallenBlocks: removedBlocks.fallenBlocks){
                    self.view.userInteractionEnabled = true
                }
            }else{
                self.view.userInteractionEnabled = true
            }
            
        }
    }
    //Gestures handling
    
    func updateHUD(){
        self.gameScene.HUDLayer.levelLabelNode.text = "\(gameLogic.level)"
        self.gameScene.HUDLayer.scoreLabelNode.text = "\(gameLogic.score)"
        self.gameScene.HUDLayer.wavesLeftLabelNode.text = "\(gameLogic.wavesLeft)"
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if (point.x >= 0 && point.x < CGFloat(NumColumns) * (BlockWidth+BlockWidthOffset) &&
            point.y >= 0 && point.y < CGFloat(NumRows) * (BlockHeight+BlockHeightOffset)) {
                return (true, Int(point.x / (BlockWidth)), Int(point.y / (BlockHeight+BlockHeightOffset)))
        } else {
            return (false, 0, 0)
        }
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