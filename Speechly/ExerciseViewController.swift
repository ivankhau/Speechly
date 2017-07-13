//
//  ExerciseViewController.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/9/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import UIKit
import AVFoundation

import SwiftyStoreKit
import PopupDialog
import EZLoadingActivity

class ExerciseViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var lyricsView: UIView!
    
    @IBOutlet weak var selectionView: UIView!
    
    @IBOutlet weak var buttonView: UIView!
    
    
    @IBOutlet weak var doneLabel: UILabel!
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var karaokeLabel: UILabel!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var personTalkingImage: UIImageView!
    @IBOutlet weak var personTalkingLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stopWatchLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    fileprivate let reuseIdentifier = "QuestionCell"
    fileprivate var questionsArray: [String] = []
    fileprivate var questionSelected: Int = 0
    //fileprivate var dialogueMutable = NSMutableAttributedString()
    fileprivate var characterCount = Int()
    fileprivate var audioPlayer: AVAudioPlayer?
    fileprivate var audioRecorder: AVAudioRecorder?
    fileprivate var timerSet = false
    fileprivate var repeatCount = 0
    fileprivate var hasRecording = false
    fileprivate var recordingPlayedAfterSpeech = false
    fileprivate var forceStopAudio = true
    var speechsynt: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var stopWatch: Timer? = nil
    var currentTime = 0
    let duration = 0.75
    
    var toggleRecordLock:Bool = true
    
    var statusDebugTimer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorder(view: lyricsView)
        addBorder(view: selectionView)
        addBorder(view: buttonView)
        
        if let currentQuestion = UserDefaults.standard.object(forKey: categoryTitle) {
            
            questionSelected = currentQuestion as! Int
        
        } else {
            UserDefaults.standard.set(0, forKey: categoryTitle)
            
        }
        
        navItem.title = categoryTitle
        setSpeaker()
        
        statusView.layer.cornerRadius = statusView.frame.size.height / 2
        statusView.layer.borderColor = UIColor(red: 237/255.0, green: 238/255.0, blue: 241/255.0, alpha: 0.8).cgColor
        statusView.layer.borderWidth = 2
        
        speakerImage.layer.cornerRadius = speakerImage.frame.size.height / 2
        speakerImage.layer.borderColor = UIColor(red: 237/255.0, green: 238/255.0, blue: 241/255.0, alpha: 1.0).cgColor
        speakerImage.layer.borderWidth = 2
        speakerImage.layer.masksToBounds = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(speakerImageTapped(tapGestureRecognizer:)))
        speakerImage.isUserInteractionEnabled = true
        speakerImage.addGestureRecognizer(tapGestureRecognizer)
        
        questionsArray = selectedQuestions!
        
        karaokeLabel.text = questionsArray[questionSelected]
        //self.dialogueMutable = NSMutableAttributedString(string: questionsArray[questionSelected], attributes: [NSFontAttributeName:UIFont(name: karaokeFont, size: CGFloat(karaokeSize))!])
        characterCount = questionsArray[questionSelected].characters.count
        
        //workaround for iOS8 Bug
        let beforeSpeechString : String = " "
        let beforeSpeech:AVSpeechUtterance = AVSpeechUtterance(string: beforeSpeechString)
        speechsynt.speak(beforeSpeech)
        
        fadeOut(finished: true)
        
    }
    
    @IBOutlet weak var chooseSpeakerTapped: UIBarButtonItem!
    
    @IBAction func chooseSpeakerTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "exerciseToSpeakerSelect", sender: self)
    }
    
    func addBorder(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        restartView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        questionSelected = questionSelected - 1
        karaokeLabel.text = questionsArray[questionSelected]
        restartView()
        UserDefaults.standard.set(questionSelected, forKey: categoryTitle)


        let indexPath = IndexPath(row: questionSelected, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        if premiumStatus == nil {
            if 0 ... 7 ~= questionSelected + 1 {
                nextQuestion()
            } else {
                print("NO ACCESS!!")
                subscribe()
            }
        } else {
            nextQuestion()
        }
    }
    
    func nextQuestion() {
        questionSelected = questionSelected + 1
        karaokeLabel.text = questionsArray[questionSelected]
        restartView()
        UserDefaults.standard.set(questionSelected, forKey: categoryTitle)

        
        let indexPath = IndexPath(row: questionSelected, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
    }
    
    

    @IBAction func doneSpeakingTapped(_ sender: Any) {
        
        if doneButton.image(for: .normal) == UIImage(named: "done.png") {
            stopRecording()
            startSpeaking()
            print("done tapped")
        } else {
            stopRecording()
            startSpeaking()
            print("replay tapped")
        }

    }
    
    @IBAction func restartRecordingTapped(_ sender: Any) {
        restartView()
    }
    
    func disableButton(button: UIButton) {
        button.isEnabled = false
        button.alpha = 0.5
    }
    func enableButton(button: UIButton) {
        button.isEnabled = true
        button.alpha = 1.0
    }

    
    func restartView() {
        toggleRecordLock = true
        speechsynt.stopSpeaking(at: AVSpeechBoundary.immediate)
        statusDebugTimer?.invalidate()
        disableButton(button: doneButton)
        disableButton(button: nextButton)
        disableButton(button: backButton)
        
        doneButton.setImage(UIImage(named: "done.png"), for: .normal)
        doneLabel.text = "Done"
        
        repeatCount = 0
        if stopWatch != nil {
        stopWatch?.invalidate()
        stopWatch = nil
        }
        
        currentTime = 0
        
        karaokeLabel.text = questionsArray[questionSelected]
        characterCount = (karaokeLabel.text?.characters.count)!

        stopWatchLabel.text = "00:00"
        tableView.reloadData()
        audioRecorder?.stop()
        recordSetup()
        hasRecording = false
        recordingPlayedAfterSpeech = false
        forceStopAudio = true
        setSpeaker()
        startSpeaking()
        
        if questionSelected == 0 {
            disableButton(button: backButton)
        } else {
            enableButton(button: backButton)
        }
        
        if questionSelected == (questionsArray.count - 1) {
            disableButton(button: nextButton)
        } else {
            enableButton(button: nextButton)
        }
        
        
        self.crappyBugFix()
        

        statusDebugTimer = Timer.scheduledTimer(timeInterval: 0.25,
                             target: self,
                             selector: #selector(self.debugTimer),
                             userInfo: nil,
                             repeats: false)
        
    }
    
    func debugTimer() {
        self.crappyBugFix()
        
        self.toggleRecordLock = false
    }
    
    func crappyBugFix() {
        self.statusView.layer.backgroundColor = UIColor(red: 4/255.0, green: 51/255.0, blue: 191/255.0, alpha: 1.0).cgColor
        self.statusImage.image = UIImage(named: "statusSpeaking.png")
        self.statusLabel.text = "\((selectedVoice?[0])!) is speaking."
        self.stopWatch?.invalidate()
        self.stopWatch = nil
        self.stopWatchLabel.text = "00:00"
        self.disableButton(button: self.doneButton)
    }
    
    func fadeIn(finished: Bool) {
        UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.statusLabel.alpha = 1
            //self.statusImage.alpha = 1
        } , completion: self.fadeOut)
    }
    
    func fadeOut(finished: Bool) {
        UIView.animate(withDuration: self.duration, delay: 0.80, options: [.curveEaseInOut], animations: {
            self.statusLabel.alpha = 0.4
            //self.statusImage.alpha = 0.4
        } , completion: self.fadeIn)
    }
    
    func toggleStopwatch() {
        if stopWatch != nil {
            //stopWatchToggleButton.setTitle("Start", for: .normal)
            stopWatch?.invalidate()
            stopWatch = nil
        } else {
            //stopWatchToggleButton.setTitle("Stop", for: .normal)

            stopWatch = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(self.stopWatchFunc),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    func stopWatchFunc() {
        self.currentTime += 1
        let minutesPortion = String(format: "%02d", self.currentTime / 60 )
        let secondsPortion = String(format: "%02d", self.currentTime % 60 )
        self.stopWatchLabel.text = "\(minutesPortion):\(secondsPortion)"
    }
    
    deinit {
        speechsynt.stopSpeaking(at: AVSpeechBoundary.immediate)
        audioPlayer?.stop()
        audioRecorder?.stop()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        speechsynt.stopSpeaking(at: AVSpeechBoundary.immediate)
        audioPlayer?.stop()
        audioRecorder?.stop()

    }
    
    func subscribe() {
        
        if premiumStatus == nil {
            let title = "UPGRADE TO PREMIUM?"
            let message = "\nUnlock every question and speaker.\n\n\(unlockPrice)"
            let popup = PopupDialog(title: title, message: message)
            let purchaseButton = DefaultButton(title: "PURCHASE PREMIUM", height: 60) {
                EZLoadingActivity.show("Processing...", disableUI: true)
                SwiftyStoreKit.purchaseProduct("unlockPremium", atomically: true) { result in
                    switch result {
                    case .success(let product):
                        print("Purchase Success: \(product.productId)")
                        UserDefaults.standard.set("Premium", forKey: "Premium")
                        premiumStatus = true
                        EZLoadingActivity.hide(true, animated: true)
                        
                        DispatchQueue.main.async {
                            self.restartView()
                        }
                        
                    case .error(let error):
                        EZLoadingActivity.hide(false, animated: true)
                        switch error.code {
                        case .unknown: print("Unknown error. Please contact support")
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        }
                    }
                }
                
            }
            let restoreButton = DefaultButton(title: "RESTORE") {
                EZLoadingActivity.show("Processing...", disableUI: true)
                SwiftyStoreKit.restorePurchases(atomically: true) { results in
                    if results.restoreFailedProducts.count > 0 {
                        print("Restore Failed: \(results.restoreFailedProducts)")
                        EZLoadingActivity.hide(false, animated: true)
                    }
                    else if results.restoredProducts.count > 0 {
                        print("Restore Success: \(results.restoredProducts)")
                        UserDefaults.standard.set("Premium", forKey: "Premium")
                        premiumStatus = true
                        EZLoadingActivity.hide(true, animated: true)
                        
                        DispatchQueue.main.async {
                            self.restartView()
                        }
                        
                    }
                    else {
                        print("Nothing to Restore")
                        EZLoadingActivity.hide(false, animated: true)
                    }
                }
                
            }
            let cancelButton = CancelButton(title: "CANCEL") {
                print("You canceled the car dialog.")
            }
            popup.addButtons([purchaseButton, restoreButton, cancelButton])
            
            self.present(popup, animated: true, completion: nil)
        } else {
            print("ALREADY SUBSCRIBED")
        }
        
    }
    
}



// AVSpeechSynthesizer
extension ExerciseViewController: AVSpeechSynthesizerDelegate {
    
    func setSpeaker() {
        speechsynt.delegate = self
        if speechsynt.isSpeaking {
            speechsynt.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        if let currentSelected = UserDefaults.standard.value(forKey: "selectedVoice") {
            selectedVoice = currentSelected as? [String]
            print("Selected: \(selectedVoice)")
        } else {
            //UserDefaults.standard.set(voicesArray[0], forKey: "selectedVoice")
            //selectedVoice = voicesArray[0]
            //print("Set default to \(voicesArray[0])")
        }
        
        speakerImage.image = UIImage(named: "\((selectedVoice?[0])!).png") ?? UIImage(named: "unknown.png")
        personTalkingLabel.text = (selectedVoice?[0])!
    }
    
    func speakerImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        self.performSegue(withIdentifier: "exerciseToSpeakerSelect", sender: self)
        // Your action
    }
    
    func startSpeaking() {
        if hasRecording == false {
            statusView.layer.backgroundColor = UIColor(red: 4/255.0, green: 51/255.0, blue: 191/255.0, alpha: 1.0).cgColor
            statusImage.image = UIImage(named: "statusSpeaking.png")
            statusLabel.text = "\((selectedVoice?[0])!) is speaking."
        } else {
            statusView.layer.backgroundColor = UIColor(red: 51/255.0, green: 191/255.0, blue: 4/255.0, alpha: 1.0).cgColor
            statusImage.image = UIImage(named: "statusPlayback.png")
            statusLabel.text = "Playing back response."
        }
        
        if speechsynt.isSpeaking {
            speechsynt.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        karaokeLabel.text = questionsArray[questionSelected]
        //self.dialogueMutable = NSMutableAttributedString(string: questionsArray[questionSelected], attributes: [NSFontAttributeName:UIFont(name: karaokeFont, size: CGFloat(karaokeSize))!])
        characterCount = questionsArray[questionSelected].characters.count
        
        let speechString : String = questionsArray[questionSelected]
        let nextSpeech:AVSpeechUtterance = AVSpeechUtterance(string: speechString)
        
        nextSpeech.voice = AVSpeechSynthesisVoice(identifier: (selectedVoice?[2])!)
        
        nextSpeech.rate = AVSpeechUtteranceDefaultSpeechRate
        
        speechsynt.speak(nextSpeech)
        forceStopAudio = false
    }
    //NSRange(location:0,length:self.repeatCount)
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 4/255.0, green: 145/255.0, blue: 191/255.0, alpha: 1.0), range: NSRange(location: 0, length: characterRange.location + characterRange.length))
        karaokeLabel.attributedText = mutableAttributedString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        karaokeLabel.attributedText = NSAttributedString(string: utterance.speechString)
        if toggleRecordLock == false {
            if hasRecording != true {
                startRecording()
            } else {
                hasRecording = false
                playRecording()
            }
        print("finished")
        }
        
    }
}

// AVAudioRecorder
extension ExerciseViewController: AVAudioPlayerDelegate {
    func recordSetup() {
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        
    }
    
    func startRecording() {
        
        statusView.layer.backgroundColor = UIColor(red: 191/255.0, green: 4/255.0, blue: 51/255.0, alpha: 1.0).cgColor
        statusImage.image = UIImage(named: "statusRecording.png")
        statusLabel.text = "Recording your response."
        toggleStopwatch()
        
        
        if audioRecorder?.isRecording == false {
            audioRecorder?.record()
            print("recording started")
        }
        
        enableButton(button: doneButton)
    }
    
    func stopRecording() {
        if doneButton.image(for: .normal) != UIImage(named: "replay.png") {
            toggleStopwatch()
        }
        hasRecording = true
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            print("recording stopped")
            
        } else {
            audioPlayer?.stop()
        }
        disableButton(button: doneButton)

    }
    
    func playRecording() {
        if audioRecorder?.isRecording == false {
            

            audioPlayer?.stop()
            
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf:
                    (audioRecorder?.url)!)
                
                
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                
                print("recording playing")
                
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !speechsynt.isSpeaking && !(audioRecorder?.isRecording)! {
            statusView.layer.backgroundColor = UIColor.lightGray.cgColor
            statusImage.image = UIImage(named: "")
            statusLabel.text = "Playback complete."
        
            doneButton.setImage(UIImage(named: "replay.png"), for: .normal)
            doneButton.isEnabled = true
            doneButton.alpha = 1.0
        
            doneLabel.text = "Replay"
        }
    }
    
    
}

extension ExerciseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if premiumStatus == nil {
            if 0 ... 7 ~= indexPath.row {
                karaokeLabel.text = questionsArray[indexPath.row]
                questionSelected = indexPath.row
                UserDefaults.standard.set(questionSelected, forKey: categoryTitle)
                restartView()
            } else {
                print("NO ACCESS!!")
                subscribe()
            }
        } else {
        karaokeLabel.text = questionsArray[indexPath.row]
        questionSelected = indexPath.row
        UserDefaults.standard.set(questionSelected, forKey: categoryTitle)
        restartView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! QuestionTableViewCell
        let question = questionsArray[indexPath.row]
        cell.questionLabel.text = question
        cell.numberLabel.text = "\(indexPath.row + 1)."
        
        if question == karaokeLabel.text {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor

        }
        
        if premiumStatus == nil {
            if 0 ... 7 ~= indexPath.row  {
                cell.questionLabel.alpha = 1.0
                cell.numberLabel.alpha = 1.0
            } else {
                cell.questionLabel.alpha = 0.1
                cell.numberLabel.alpha = 0.1
            }
        } else {
            cell.questionLabel.alpha = 1.0
            cell.numberLabel.alpha = 1.0
        }
        
        
        
        return cell
    }
}


