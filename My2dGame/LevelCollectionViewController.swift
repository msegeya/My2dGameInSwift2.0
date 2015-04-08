//
//  LevelCollectionViewController.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.04.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation
import UIKit

let reuseIdentifier = "collCell"


class LevelCollectinoViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, LevelPopUpDelegate {
    
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var vc: LevelPopUpViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.scrollView.delegate = nil
    }
    
    func gameDidStart(level: Level) {
        self.vc = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("GameViewController") as GameViewController
        
        vc.choosenLevel = level
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 36
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CollectionViewCell
        cell.title.text = "Level \(indexPath.item + 1)"
        
        var imgName = "star"
        
        if indexPath.item > 8{
            imgName = "grayStar"
        }

        cell.pinImage.image = UIImage(named: imgName)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.vc = storyboard.instantiateViewControllerWithIdentifier("LevelPopUpViewController") as LevelPopUpViewController
            
            if let level = levelManager.getLevel(indexPath.item){
                self.vc.delegate = self
                vc.showInView(self.view, choosenLevel: level, animated: true)
            }
            
            return false
    }
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            return CGSize(width: 80, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }

}


