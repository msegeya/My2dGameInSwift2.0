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
            
            let data: NSData? = try! NSData(contentsOfFile: path, options: NSDataReadingOptions())
            if let data = data {
                
                let json = JSON(data: data)
                
                self.numLevels = json["numLevels"].intValue
                
                for level in json["levels"].array!{
                    array.append(
                        Level(id: level["id"].int!,
                            delay: (level["delay"].double!),
                            numWaves: (level["numWaves"].int!),
                            isPassed: (level["isPassed"].bool!),
                            score: (level["score"].int!)))
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