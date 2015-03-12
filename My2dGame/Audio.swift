//
//  Audio.swift
//  My2dGame
//
//  Created by Karol Kedziora on 12.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//
import AVFoundation

class Audio {
    var sounds: Bool = true
    var music: Bool = true{
        didSet{
            if music{
                backgroundMusicPlayer.play()
            }else{
                backgroundMusicPlayer.stop()
            }
        }
    }
    
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    init(){
        var backgroundMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BackgroundSound", ofType: "mp3")!)
        
        var error:NSError?
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic, error: &error)
        backgroundMusicPlayer.numberOfLoops = -1 //infinite loop
        backgroundMusicPlayer.prepareToPlay()
    }
    
    func reset(){
        backgroundMusicPlayer.currentTime = 0
        backgroundMusicPlayer.volume = 1
        if music{
            backgroundMusicPlayer.play()
        }
    }
}