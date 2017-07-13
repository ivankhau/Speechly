//
//  FirstLoginViewController.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/24/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import UIKit
import AVFoundation

class FirstLoginViewController: UIViewController {

    @IBOutlet weak var understandButton: UIButton!
    @IBOutlet weak var backgroundLabel: UILabel!
    var speechsynt: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCorner(object: backgroundLabel)
        backgroundLabel.layer.masksToBounds = true
        backgroundLabel.alpha = 0.8
        addCorner(object: understandButton)

        // Do any additional setup after loading the view.
    }
    
    func addCorner(object: AnyObject) {
        object.layer.cornerRadius = 3
    }

    @IBAction func understandTapped(_ sender: Any) {
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (audioGranted: Bool) -> Void in
            if (audioGranted) {
                print("Audio Granted")
                
                DispatchQueue.main.async {
                
                    UserDefaults.standard.set(true, forKey: "termsAccepted")
                    self.performSegue(withIdentifier: "showToMainSegue", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    
                    UserDefaults.standard.set(true, forKey: "termsAccepted")
                    self.performSegue(withIdentifier: "showToMainSegue", sender: self)
                }

                print("Audio Denied")
            }
        })
        
    }
    
    //func AVCaput
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        

    }


}
