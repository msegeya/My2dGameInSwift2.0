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

class MainMenuViewController: UIViewController, MenuDelegate, FBSDKLoginButtonDelegate {
    var gameCenter: EasyGameCenter!
    //var fbLoginView : FBLoginView!
    
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
     
        let button = FBSDKLoginButton(frame: CGRectMake(0, self.view!.frame.height - 70, 150, 40))
        button.center.x = self.view!.center.x
        button.delegate = self
        button.readPermissions = ["public_profile", "email", "user_friends"]
        view.addSubview(button)
    }
    
    //Facebook integration, delegate methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            print("error")
        } else if result.isCancelled {
            print("cancelled")
        } else {
            print("token: \(result.token.tokenString)")
            print("user_id: \(result.token.userID)")
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }
                else
                {
                    print("fetched user: \(result)")
                    let userName : NSString = result.valueForKey("name") as! NSString
                    print("User Name is: \(userName)")
                    let userEmail : NSString = result.valueForKey("email") as! NSString
                    print("User Email is: \(userEmail)")
                }
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out...")
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

