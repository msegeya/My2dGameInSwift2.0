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

class GameViewController: UIViewController, GameDelegate, PopUpDelegate {

    var scene: GameScene!
    var menuScene: MenuScene!
    var game: Game!
    
    var timePassed = 0.0
    var isGamePaused: Bool = false
    
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var sounds: Switch = .On{
        didSet{
            if sounds == .On{
                scene.sound = .On
            }else{
                scene.sound = .Off
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseGameSceneNotificationReceived:", name:"pauseGameScene", object: nil)
        
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.ignoresSiblingOrder = true
        
        menuScene = MenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .AspectFill
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        
        game = Game()
        game.delegate = self
        game.beginGame()
        
        scene.pauseGame = gameDidPause
        scene.resumeGame = gameDidResume
        scene.popUp.delegate = self
        
        
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
        backgroundMusicPlayer.numberOfLoops = 100
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
    
    //PopUpDelegates
    func gameDidPause(){
        isGamePaused = true
        scene.showPopUpAnimation()
        
        timePassed = scene.lastTick!.timeIntervalSinceNow
        scene.stopTicking()
    }
    func gameDidResume(){
        scene.hidePopUpAnimation(){
            let newLastTickValue = NSDate().dateByAddingTimeInterval(NSTimeInterval(self.timePassed))
            self.scene.lastTick = newLastTickValue
            self.isGamePaused = false
        }
    }
    func gameDidExit(){
        println("wyjscie do sceny menu")
        //Finish game and back to the Menu Scene
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
        view.userInteractionEnabled = true
        scene.tickLengthMillis = TickLengthLevelOne
        scene.startTicking()
        
        scene.HUDLayer.levelLabelNode.text = String("\(game.level)")
        scene.HUDLayer.scoreLabelNode.text = String("\(game.score)")
        scene.HUDLayer.wavesLeftLabelNode.text = String("\(game.wavesLeft)")
    }
    
    func gameDidEnd(game: Game) {
        view.userInteractionEnabled = false

        scene.stopTicking()
        scene.animateClearingScene(){
            game.beginGame()
        }
    }
    
    func gameDidLevelUp(game: Game) {
        
        view.userInteractionEnabled = false
        scene.stopTicking()
        
        if(scene.tickLengthMillis >= 1800){
            scene.tickLengthMillis -= 100
        }else if scene.tickLengthMillis > 600{
            scene.tickLengthMillis -= 50
        }
        
        let results = game.sumUpPointsInColumns()
        scene.animateSummaryResults(results, columns: game.columnArray){
            game.beginGame()
        }
    }
    
    func didTick(){
        scene.gameLayer.columnsLayer.userInteractionEnabled = false
        
        if let newColumn = game.newColumn(){
            scene.HUDLayer.wavesLeftLabelNode.text = String(format: "%ld", game.wavesLeft)
            scene.animateAddingSpritesForColumn(newColumn){
                self.scene.gameLayer.columnsLayer.userInteractionEnabled = true
                self.scene.animateAddingNextColumnPreview(self.game.nextColumn!)
            }
        }
        if game.wavesLeft == 0{
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
            if let newColumn = game.swipeColumn(column){
                scene.animateSwipingColumn(column, newColumn: newColumn, direction: sender.direction)
                scene.HUDLayer.scoreLabelNode.text = "\(game.score)"
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
            
            let removedBlocks = game.removeBlocks(column, row: row)
            
            if(removedBlocks.blocksRemoved.count > 0){
                scene.HUDLayer.scoreLabelNode.text = String(game.score)
                scene.animateRemovingBlocksSprites(removedBlocks.blocksRemoved, fallenBlocks: removedBlocks.fallenBlocks){
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