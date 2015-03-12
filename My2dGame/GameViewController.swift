//
//  GameViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

enum Switch {
    case On, Off
}

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

class GameViewController: UIViewController, GameDelegate, PopUpDelegate, MenuDelegate {

    var gameScene: GameScene!
    var menuScene: MenuScene!
    var gameLogic: Game!
    
    var timePassed = 0.0
    var isGamePaused: Bool = true
    
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var sounds: Switch = .On{
        didSet{
            if sounds == .On{
                gameScene.sound = .On
            }else{
                gameScene.sound = .Off
            }
        }
    }
    
    var music: Switch = .On{
        didSet{
            if music == .On{
                backgroundMusicPlayer.play()
            }else{
                backgroundMusicPlayer.stop()
            }
        }
    }
    
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
        
        
        //Audio
        var backgroundMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BackgroundSound", ofType: "mp3")!)

        var error:NSError?
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic, error: &error)
        backgroundMusicPlayer.numberOfLoops = -1 //infinite loop
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        //Audio

        skView.presentScene(menuScene)
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

        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.tick = didTick
        
        gameScene.pauseGame = gameDidPause
        gameScene.resumeGame = gameDidResume
        gameScene.popUp.delegate = self
        
        skView.presentScene(gameScene, transition: transition)
        backgroundMusicPlayer.volume = 1.0
        delay(0.7){
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
        
        timePassed = gameScene.lastTick!.timeIntervalSinceNow
        gameScene.stopTicking()
    }
    func gameDidResume(){
        gameScene.hidePopUpAnimation(){
            let newLastTickValue = NSDate().dateByAddingTimeInterval(NSTimeInterval(self.timePassed))
            self.gameScene.lastTick = newLastTickValue
            self.isGamePaused = false
        }
    }
    func gameDidExitToMenu(){
        backgroundMusicPlayer.volume = 0.0
        let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5)
        skView.presentScene(menuScene, transition: transition)
    }
    func musicDidSwitch(){
        if music == .On{
            music = .Off
        }else{
            music = .On
        }
    }
    func soundDidSwitch(){
        if sounds == .On{
            sounds = .Off
        }else{
            sounds = .On
        }
    }
    //PopUpDelagates
    
    
    //GameDelegates
    func gameDidBegin(game: Game) {
        isGamePaused = false
        view.userInteractionEnabled = true
        gameScene.tickLengthMillis = TickLengthLevelOne
        gameScene.startTicking()
        
        gameScene.HUDLayer.levelLabelNode.text = String("\(game.level)")
        gameScene.HUDLayer.scoreLabelNode.text = String("\(game.score)")
        gameScene.HUDLayer.wavesLeftLabelNode.text = String("\(game.wavesLeft)")
    }
    
    func gameDidEnd(game: Game) {
        view.userInteractionEnabled = false

        gameScene.stopTicking()
        gameScene.animateClearingScene(){
            game.beginGame()
        }
    }
    
    func gameDidLevelUp(game: Game) {
        
        view.userInteractionEnabled = false
        gameScene.stopTicking()
        
        if(gameScene.tickLengthMillis >= 1800){
            gameScene.tickLengthMillis -= 100
        }else if gameScene.tickLengthMillis > 600{
            gameScene.tickLengthMillis -= 50
        }
        
        let results = game.sumUpPointsInColumns()
        gameScene.animateSummaryResults(results, columns: game.columnArray){
            game.beginGame()
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
            println("czas na doczyszczenie planszy")
            //komunikat o ostatniej fali i odliczanie stałego odcinka czasu dla każdego lvlu na dokonczenie
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
            println("sukces \(column), \(row)")
            view.userInteractionEnabled = false
            
            let removedBlocks = gameLogic.removeBlocks(column, row: row)
            
            if(removedBlocks.blocksRemoved.count > 0){
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