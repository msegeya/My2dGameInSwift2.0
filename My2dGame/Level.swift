//
//  Level.swift
//  My2dGame
//
//  Created by Karol Kedziora on 06.04.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//

import Foundation

class Level {
    let id: Int!
    let delay: Double!
    let numWaves: Int!
    
    var isPassed: Bool!
    var score: Int!
    
    init(id: Int, delay: Double, numWaves: Int, isPassed: Bool, score: Int){
        self.id = id
        self.delay = delay
        self.numWaves = numWaves
        self.isPassed = isPassed
        self.score = score
    }
}