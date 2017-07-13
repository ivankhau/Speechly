//
//  TongueTwisterViewController.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/9/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//
/*
import UIKit
import AVFoundation

class TongueTwisterViewControllerDeprecated: UIViewController {
    
    var tongueTwisterMutable = NSMutableAttributedString()
    
    @IBOutlet weak var karaokeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tongueTwisterMutable = NSMutableAttributedString(string: tongueTwister as String, attributes: [NSFontAttributeName:UIFont(name: karaokeFont, size: CGFloat(karaokeSize))!])
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var seconds = [0.2, 0.448, 0.888, 1.4, 1.709, 1.935, 2.464, 3.0, 3.48, 3.688, 3.889, 4.4, 4.878, 5.308, 5.8, 6.283]
    var number = [1, 5, 9, 13, 15, 20, 25, 30, 34, 38, 43, 48, 53, 58, 64, 71]
    
    @IBAction func playTapped(_ sender: Any) {
        
        let path = Bundle.main.path(forResource: "thebugandthebearslow", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            audioPlayer = sound
            let asset = AVURLAsset(url: url)
            print(Double(CMTimeGetSeconds(asset.duration)))
            selectedAudioLength = Double(CMTimeGetSeconds(asset.duration))
            sound.prepareToPlay()
            sound.enableRate = true
            sound.rate = 1.0
            sound.stop()
            sound.play()
            
            for (index, second) in seconds.enumerated() {
                let when = DispatchTime.now() + second - 0.2
                
                DispatchQueue.main.asyncAfter(deadline: when) {
                    
                    //self.tongueTwisterMutable.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location:0,length:self.number[index]))
                    //self.karaokeLabel.attributedText = self.tongueTwisterMutable
                    
                    UIView.transition(with: self.karaokeLabel, duration: 0.15, options: .transitionCrossDissolve, animations: { () -> Void in
                        self.tongueTwisterMutable.addAttribute(
                            NSForegroundColorAttributeName,
                            value: UIColor.red,
                            range: NSRange(location:0,length:self.number[index]))
                        self.karaokeLabel.attributedText = self.tongueTwisterMutable
                    }, completion: nil)
                    
                    
                    if index == self.seconds.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            
                            self.tongueTwisterMutable.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location:0,length:self.number[index]))
                            self.karaokeLabel.attributedText = self.tongueTwisterMutable
                            
                        }
                    }
                }
                
            }
            
            
        } catch {
            // couldn't load file :(
        }
        
        
        
    }
    
}*/
