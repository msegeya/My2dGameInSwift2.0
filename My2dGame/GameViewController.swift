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

class GameViewController: UIViewController, GameDelegate, PopUpDelegate {

    var scene: GameScene!
    var game: Game!
    
    var timePassed = 0.0
    var isGamePaused: Bool = false
    
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.ignoresSiblingOrder = true
        
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
        
        
        skView.presentScene(scene)
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
        if backgroundMusicPlayer.playing{
            backgroundMusicPlayer.stop()
        }else{
            backgroundMusicPlayer.play()
        }
    }
    func soundDidSwitch(){
        if  scene.sound == .On{
            scene.sound = .Off
        }else{
            scene.sound = .On
        }
    }
    //PopUpDelagates
    
    
    //GameDelegates
    func gameDidBegin(game: Game) {
        view.userInteractionEnabled = true
        scene.tickLengthMillis = TickLengthLevelOne
        scene.startTicking()
        
        scene.levelLabelNode.text = String("\(game.level)")
        scene.scoreLabelNode.text = String("\(game.score)")
        scene.wavesLeftLabelNode.text = String("\(game.wavesLeft)")
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
        scene.blocksLayer.userInteractionEnabled = false
        
        if let newColumn = game.newColumn(){
            scene.wavesLeftLabelNode.text = String(format: "%ld", game.wavesLeft)
            scene.animateAddingSpritesForColumn(newColumn){
                self.scene.blocksLayer.userInteractionEnabled = true
                self.scene.animateAddingNextColumnPreview(self.game.nextColumn!)
            }
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
                scene.scoreLabelNode.text = "\(game.score)"
            }
        }
    }
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        if isGamePaused{
            return
        }
        var currentPoint = sender.locationInView(self.view)
        
        currentPoint.x -= 36
        currentPoint.y -= 27
        if currentPoint.y-269 < 0{
            currentPoint.y = abs(currentPoint.y-269)
        }else{
            currentPoint.y = -(currentPoint.y-269)
        }
        
        let (success, column, row) = convertPoint(currentPoint)
        if success {
            
            view.userInteractionEnabled = false
            
            let removedBlocks = game.removeBlocks(column, row: row)
            
            if(removedBlocks.blocksRemoved.count > 0){
                scene.scoreLabelNode.text = String(game.score)
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
        if (point.x >= 0 && point.x < CGFloat(NumColumns) * BlockWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows) * BlockHeight) {
                return (true, Int(point.x / BlockWidth), Int(point.y / BlockHeight))
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