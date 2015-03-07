//
//  GameViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameDelegate {
    
    var scene: GameScene!
    var game: Game!
    
    var timePassed = 0.0

    @IBAction func pauseButtonTapped(sender : AnyObject) {
        
        scene.view?.paused = true
        
        self.timePassed = scene.lastTick!.timeIntervalSinceNow
        
        //        popUpViewController = PopUpViewController(nibName: "PopUpView", bundle: nil)
        //        popUpViewController.delegate = self
        //        self.popUpViewController.showInView(self.view, withMessage: "PAUSED!", animated: true)
    }

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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("didTap:"))
        skView.addGestureRecognizer(tapGesture)
        
        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: Selector("didSwipe:"))
        swipeGestureUp.direction = .Up
        skView.addGestureRecognizer(swipeGestureUp)
        
        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: Selector("didSwipe:"))
        swipeGestureDown.direction = .Down
        skView.addGestureRecognizer(swipeGestureDown)
        
        skView.presentScene(scene)
    }
    
    //    func didResumed() {
    //        let newLastTickValue = NSDate().dateByAddingTimeInterval(NSTimeInterval(timePassed))
    //        scene.lastTick = newLastTickValue
    //        scene.view?.paused = false
    //    }
    
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
        
        //scene.playSound("levelUp.wav")
        
        let results = game.sumUpPointsInColumns()
        scene.animateSummaryResults(results, columns: game.columnArray){
            game.beginGame()
        }
    }
    
    func didTick(){
        view.userInteractionEnabled = false
        
        if let newColumn = game.newColumn(){
            scene.wavesLeftLabelNode.text = String(format: "%ld", game.wavesLeft)
            scene.animateAddingSpritesForColumn(newColumn){
                self.view.userInteractionEnabled = true
                self.scene.animateAddingNextColumnPreview(self.game.nextColumn!)
            }
        }
    }
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        let currentPoint = sender.locationInView(sender.view)
     
        var tmpPoint = currentPoint
        tmpPoint.x -= 36
        tmpPoint.y = 0
        
        let (success, column, row) = convertPoint(tmpPoint)
        if success {
            if let newColumn = game.swipeColumn(column){
                scene.animateSwipingColumn(column, newColumn: newColumn, direction: sender.direction)
            }
        }
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        
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