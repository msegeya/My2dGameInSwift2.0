//
//  Audio.swift
//  My2dGame
//
//  Created by Karol Kedziora on 12.03.2015.
//  Copyright (c) 2015 Karol Kedziora. All rights reserved.
//
import AVFoundation
import MediaPlayer

class Audio {
    let defaults = NSUserDefaults.standardUserDefaults()
    let audioSession = AVAudioSession.sharedInstance()
    var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    var error:NSError?
    
    var sounds: Bool{
        didSet{
            if sounds{
                defaults.setBool(true, forKey: "sounds")
            }else{
                defaults.setBool(false, forKey: "sounds")
            }
        }
    }
    var music: Bool = false{
        didSet{
            if music{
                audioSession.setCategory(AVAudioSessionCategorySoloAmbient, error: nil)
                backgroundMusicPlayer.play()
                defaults.setBool(true, forKey: "music")
            }else{
                audioSession.setCategory(AVAudioSessionCategoryAmbient, error: nil)
                backgroundMusicPlayer.stop()
                defaults.setBool(false, forKey: "music")
            }
        }
    }
    
    init(){
        var backgroundMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BackgroundSound", ofType: "mp3")!)
        
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic, error: &error)
        backgroundMusicPlayer.numberOfLoops = -1 //infinite loop
        
        if audioSession.otherAudioPlaying{
            audioSession.setCategory(AVAudioSessionCategoryAmbient, error: nil)
        }else{
            backgroundMusicPlayer.prepareToPlay()
            
            if let musicFromDefaults = defaults.boolForKey("music") as Bool?
            {
                self.music = musicFromDefaults
            }else{
                self.music = true
            }
        }
        
        if let soundsFromDefaults = defaults.boolForKey("sounds") as Bool?
        {
            self.sounds = soundsFromDefaults
        }else{
            self.sounds = true
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