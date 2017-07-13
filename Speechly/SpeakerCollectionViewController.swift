//
//  SpeakerCollectionViewController.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/20/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import UIKit
import AVFoundation

import SwiftyStoreKit
import PopupDialog
import EZLoadingActivity

class SpeakerCollectionViewController: UICollectionViewController {
    
    var voicesArray: [AVSpeechSynthesisVoice] = []
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "SpeakerCell"
    override func viewDidLoad() {
        
        
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            
            if voice.language.contains("en") {
                
                if voice.language.contains("en-US") {
                    voicesArray.insert(voice, at: 0)
                } else {
                    voicesArray.append(voice)
                }
                
            }
            
        }
        
        for (index, voice) in voicesArray.enumerated() {
            if voice.name == "Aaron" || voice.name == "Nicky" {
                let tempVoice = voice
                voicesArray.remove(at: index)
                voicesArray.insert(tempVoice, at: 0)
            }
        }
        
        if let currentSelected = UserDefaults.standard.value(forKey: "selectedVoice") {
            selectedVoice = currentSelected as? [String]
            print("Selected: \(selectedVoice)")
        } else {
            UserDefaults.standard.set([voicesArray[0].name, voicesArray[0].language, voicesArray[0].identifier], forKey: "selectedVoice")
            selectedVoice = [voicesArray[0].name, voicesArray[0].language, voicesArray[0].identifier]
            print("Set default to \(selectedVoice)")
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) + 33)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        collectionView!.collectionViewLayout = layout
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
                            self.collectionView?.reloadData()
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
                        EZLoadingActivity.hide(true, animated: true)
                        UserDefaults.standard.set("Premium", forKey: "Premium")
                        premiumStatus = true
                        EZLoadingActivity.hide(true, animated: true)
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
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

// MARK: - UICollectionViewDataSource
extension SpeakerCollectionViewController {
    //1
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return voicesArray.count
    }
    
    //3
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as! SpeakerCollectionViewCell
        let speaker = voicesArray[indexPath.row]
        
        //1
        cell.speakerLabel.text = "\(speaker.name)\n\(speaker.language)"
        
        
        let quality = speaker.identifier as String
        if quality.contains("_male") || speaker.name == "Fred" || speaker.name == "Daniel" {
            cell.layer.backgroundColor = UIColor(red: 153/255.0, green: 204/255.0, blue: 255/255.0, alpha: 1.0).cgColor
            cell.speakerImage.image = UIImage(named: "\(speaker.name).png") ?? UIImage(named: "unknown.png")
        } else if quality.contains("_female") || speaker.name == "Samantha" || speaker.name == "Karen" || speaker.name == "Tessa" || speaker.name == "Moira" {
            cell.layer.backgroundColor = UIColor(red: 240/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0).cgColor
            cell.speakerImage.image = UIImage(named: "\(speaker.name).png") ?? UIImage(named: "unknown.png")
        } else {
            cell.layer.backgroundColor = UIColor(red: 231/255.0, green: 232/255.0, blue: 236/255.0, alpha: 1.0).cgColor
            cell.speakerImage.image = UIImage(named: "unknown.png")
        }
        
        
        if speaker.name == (selectedVoice?[0])! {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 4
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        if premiumStatus == nil {
            if 0 ... 1 ~= indexPath.row  {
                //cell.speakerImage.alpha = 1.0
                //cell.speakerLabel.alpha = 1.0
                cell.layer.opacity = 1.0
            } else {
                //cell.speakerImage.alpha = 0.1
                //cell.speakerLabel.alpha = 0.1
                cell.layer.opacity = 0.2
            }
        } else {
            //cell.speakerImage.alpha = 1.0
            //cell.speakerLabel.alpha = 1.0
            cell.layer.opacity = 1.0
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if premiumStatus == nil {
            if 0 ... 1 ~= indexPath.row  {
                selectedVoice = [voicesArray[indexPath.row].name, voicesArray[indexPath.row].language, voicesArray[indexPath.row].identifier]
                print(selectedVoice)
                UserDefaults.standard.set(selectedVoice, forKey: "selectedVoice")
                self.collectionView?.reloadData()
            } else {
                print("Access Denied!!")
                self.subscribe()
            }
        } else {
            selectedVoice = [voicesArray[indexPath.row].name, voicesArray[indexPath.row].language, voicesArray[indexPath.row].identifier]
            print(selectedVoice)
            UserDefaults.standard.set(selectedVoice, forKey: "selectedVoice")
            self.collectionView?.reloadData()
        }
    }

    

}


