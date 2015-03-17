//
//  Audio.swift
//  My2dGame
//
//  Created by Karol Kedziora on 12.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//
import AVFoundation

class Audio {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var sounds: Bool{
        didSet{
            if sounds{
                defaults.setBool(true, forKey: "sounds")
            }else{
                defaults.setBool(false, forKey: "sounds")
            }
        }
    }
    var music: Bool{
        didSet{
            if music{
                backgroundMusicPlayer.play()
                defaults.setBool(true, forKey: "music")
            }else{
                backgroundMusicPlayer.stop()
                defaults.setBool(false, forKey: "music")
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

        if let soundsFromDefaults = defaults.boolForKey("sounds") as Bool?
        {
            self.sounds = soundsFromDefaults
        }else{
            self.sounds = true
        }
        if let musicFromDefaults = defaults.boolForKey("music") as Bool?
        {
            self.music = musicFromDefaults
        }else{
            self.music = true
        }
    }
    
    func reset(){
        backgroundMusicPlayer.currentTime = 0
        backgroundMusicPlayer.volume = 1
        if music{
            backgroundMusicPlayer.play()
        }
    }
}