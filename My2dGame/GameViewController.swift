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

enum Direction{
    case Up, Down, Left, Right
}

class GameViewController: UIViewController, GameDelegate, PopUpDelegate, MenuDelegate, ColumnLayerDelegate, FBLoginViewDelegate {
    
    var gameCenter: GameCenter!
    var fbLoginView : FBLoginView!
    
    var gameScene: GameScene!
    var menuScene: MenuScene!
    var gameLogic: Game!
    
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
        
        menuScene = MenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .AspectFill
        menuScene.thisDelegate = self
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        
        gameLogic = Game()
        gameLogic.delegate = self
        
        skView.presentScene(menuScene)
        
        //      self.gameCenter = GameCenter(rootViewController: self)
        
        //        /* Open Windows Game Center if player not login in Game Center */
        //        self.gameCenter.loginToGameCenter() {
        //            (result: Bool) in
        //            if result {
        //                /* Player is login in Game Center OR Open Windows for login in Game Center */
        //            } else {
        //                /* Player is not login in Game Center */
        //            }
        //        }
        
        
        //Adding facebook login/logout button to menu scene
        fbLoginView = FBLoginView(readPermissions: ["public_profile", "email", "user_friends"])
        fbLoginView.frame = CGRectOffset(fbLoginView.frame,
            (self.view!.center.x - (fbLoginView.frame.size.width / 2)), self.view!.frame.height - 70);
        fbLoginView.delegate = self
        menuScene.view?.addSubview(fbLoginView)
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
    
    
    //Facebook integration, delegate methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")
        
        var alert = UIAlertController(title: "Logged in!", message: "Hello \(user.first_name)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    //Facebook integration, delegate methods
    
    
    //MenuDelegates
    func startGame() {
        fbLoginView.hidden = true
        let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.3)
        
        self.gameScene.tickLengthMillis = TickLengthLevelOne
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.tick = didTick
        
        gameScene.pauseGame = gameDidPause
        gameScene.resumeGame = gameDidResume
        gameScene.popUp.delegate = self
        
        gameScene.gameLayer.delegate = self
        
        skView.presentScene(gameScene, transition: transition)
        
        delay(0.4){
            audio.reset()
            self.gameLogic.reset()
            self.gameScene.tickLengthMillis = TickLengthLevelOne
            self.updateHUD()
            self.gameLogic.beginGame()
            self.gameScene.HUDLayer.userInteractionEnabled = true
            self.gameScene.gameLayer.userInteractionEnabled = true
            self.gameScene.animateAddingNextColumnPreview(self.gameLogic.nextColumn!)
        }
    }
    func showHighscore() {
        //show highscore scene
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
        let transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.5)
        skView.presentScene(menuScene, transition: transition)
        delay(0.5){
            self.fbLoginView.hidden = false
        }
        
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
        self.gameScene.gameLayer.levelLabelNode.text = NSLocalizedString("Level", comment: "Level") + ": \(gameLogic.level)"
        self.gameScene.gameLayer.scoreLabelNode.text = NSLocalizedString("Score", comment: "Score") + ": \(gameLogic.score)"
        self.gameScene.HUDLayer.wavesLeftLabelNode.text = "\(gameLogic.wavesLeft)"
    }
    func updateHUD(label: String){
        switch label{
        case "level":
            self.gameScene.gameLayer.levelLabelNode.text = NSLocalizedString("Level", comment: "Level") + ": \(gameLogic.level)"
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