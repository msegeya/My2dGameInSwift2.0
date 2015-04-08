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
    
    init(){

        
        let filename = "levels"
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var error: NSError?
            let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            if let data = data {
            
                let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)

                for (index: String, level: JSON) in json["levels"] {
                    
                    array.append(
                        Level(id: level["id"].int!,
                            delay: level["delay"].double!,
                            numWaves: level["numWaves"].int!,
                            isPassed: level["isPassed"].bool!,
                            score: level["score"].int!)
                    )
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