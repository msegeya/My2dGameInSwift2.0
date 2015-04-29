//
//  Levels.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.04.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation


class Levels {
    var array = Array<Level>()
    var numPassedLevels = 0{
        didSet{
            if oldValue < numPassedLevels{
                 defaults.setInteger(numPassedLevels, forKey: "numPassedLevels")
            }
        }
    }
    var numLevels = 0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    init(){
        let filename = "levels"
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var error: NSError?
            let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            if let data = data {
            
//                let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
//
//                for (index: String, level: JSON) in json["levels"] {
//                    array.append(
//                        Level(id: level["id"].int!,
//                            delay: level["delay"].double!,
//                            numWaves: level["numWaves"].int!,
//                            isPassed: level["isPassed"].bool!,
//                            score: level["score"].int!)
//                    )
//                }
                
                let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error)
                
                if let levels = jsonOptional as? Dictionary<String, AnyObject> {
                    self.numLevels = levels["numLevels"] as! Int
                    
                    for var i = 0; i < numLevels; ++i{
                        if let level = levels["levels"]![i] as? Dictionary<String, AnyObject>{
                            array.append(
                                Level(id: level["id"] as! Int,
                                delay: level["delay"] as! Double,
                                numWaves: level["numWaves"] as! Int,
                                isPassed: level["isPassed"] as! Bool,
                                score: level["score"] as! Int))
                        }
                    }
                }
                if let numPassedLevelsFromDefaults = defaults.integerForKey("numPassedLevels") as Int?{
                    self.numPassedLevels = numPassedLevelsFromDefaults
                }else{
                    defaults.setInteger(0, forKey: "numPassedLevels")
                }
            }
        }
    }
    
    func getLevel(id: Int) -> Level?{
        if id < array.count && id >= 0{
            return array[id]
        }
        return nil
    }
}