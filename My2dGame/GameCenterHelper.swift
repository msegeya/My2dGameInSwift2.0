//
//  GameCenterHelper.swift
//  My2dGame
//
//  Created by Karol Kedziora on 12.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import GameKit

class GCHelper: NSObject{
    class var sharedInstance: GCHelper {
        struct Static {
            static let instance = GCHelper()
        }
        return Static.instance
    }
    
    var authenticated = false
    
    override init(){
        super.init()
    }
    
    class func authenticateLocalUser() {
        GCHelper.sharedInstance.authenticateLocalUser()
    }
    
    func authenticateLocalUser() {
        println("Authenticating local user...")
        if GKLocalPlayer.localPlayer().authenticated == false {
            GKLocalPlayer.localPlayer().authenticateHandler = { (view, error) in
                if error == nil {
                    self.authenticated = true
                } else {
                    println("\(error.localizedDescription)")
                }
            }
        } else {
            println("Already authenticated")
        }
    }
    func authenticateLocalPlayer() {
        var localPlayer : GKLocalPlayer!
        localPlayer.authenticateHandler = {(viewController : GameViewController!, error : NSError!) -> Void in
            if viewController != nil {
                self.presentViewController(viewController, animated: true, completion: nil)
            } else {
                if localPlayer.authenticated {
                    self.gameCenterEnabled = true
                    
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String!, error : NSError!) -> Void in
                        if error != nil {
                            println(error.localizedDescription)
                        } else {
                            self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
                    
                } else {
                    self.gameCenterEnabled = false
                }
            }
        }
    }
}
