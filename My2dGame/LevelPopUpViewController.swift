//
//  LevelPopUpViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.04.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation
import QuartzCore

protocol LevelPopUpDelegate{
    func gameDidStart(level: Level)
}

@objc class LevelPopUpViewController: UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var wavesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var starsImage: UIImageView!
    
    var choosenLevel: Level!
    
    var delegate: LevelPopUpDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func showInView(aView: UIView!, choosenLevel: Level, animated: Bool)
    {
        aView.addSubview(self.view)
        self.choosenLevel = choosenLevel
        
        levelLabel!.text = "Level \(choosenLevel.id)"
        wavesLabel!.text = "Number of waves: \(choosenLevel.numWaves)"
        scoreLabel!.text = "Score: \(choosenLevel.score)"
        starsImage!.image = UIImage(named: "Stars1")
        
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                    
                    self.delegate.gameDidStart(self.choosenLevel)
                }
        });
    }

    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
}