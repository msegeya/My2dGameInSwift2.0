//
//  MainMenuViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 03.04.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation

import UIKit
import SpriteKit

protocol MenuDelegate {
    func startGame()
    func showHighscore()
}

let levelManager: Levels = Levels()

class MainMenuViewController: UIViewController, MenuDelegate, FBLoginViewDelegate {
    var gameCenter: GameCenter!
    var fbLoginView : FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        view.addSubview(fbLoginView)
        
        var x = levelManager.getLevel(0)
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

    }
    func showHighscore() {
        //show highscore scene
    }
    //MenuDelegates
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(true)
    }

}

