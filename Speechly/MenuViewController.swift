//
//  MenuViewController.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/12/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import UIKit
import PopupDialog

import SwiftyStoreKit
import StoreKit

import EZLoadingActivity

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscriptionButton: UIBarButtonItem!
    
    let sectiono = ["Socializing Questions","Interview Questions"]
    let items = [["On a Date","Making Friends"],["General","Unusual", "Software Engineering", "Engineering","Lawyer","Medical School","Accounting","Marketing","Nursing","Sales"]]
    
    let allQuestions = AllQuestions()
    var selectedPOOPOOs  : [String] = []
    
    @IBAction func settingsTapped(_ sender: Any) {
        EZLoadingActivity.show("Processing...", disableUI: true)
    }
    
    @IBAction func subscribeTapped(_ sender: Any) {
        if premiumStatus == nil {
            subscribe()
        } else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.value(forKey: "Premium") != nil {
            premiumStatus = true
        }
        
        //premiumStatus = true
        
        setSubscribeButton()
        setTitle()
        
        SwiftyStoreKit.retrieveProductsInfo(["unlockPremium"]) { result in
            
            for product in result.retrievedProducts {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                
                unlockPrice = "\(priceString)"
                
            }
            
            for invalidProductId in result.invalidProductIDs {
                print("Could not retrieve product info. Invalid product identifier: \(invalidProductId)")
            }
            

        }

    }
    
    func setSubscribeButton() {
        if premiumStatus != nil {
            subscribeButton.setTitle("PREMIUM", for: .normal)
        } else {
            subscribeButton.setTitle("FREE", for: .normal)
        }
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
                        self.subscribeButton.setTitle("PREMIUM", for: .normal)
                        EZLoadingActivity.hide(true, animated: true)
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
                        self.subscribeButton.setTitle("PREMIUM", for: .normal)
                        EZLoadingActivity.hide(true, animated: true)
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
    

    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {

        if UserDefaults.standard.value(forKey: "selectedVoice") == nil {
            self.performSegue(withIdentifier: "menuToSpeakerSegue", sender: self)
        }
        setSubscribeButton()
    }
    
    func setTitle() {
        let longTitleLabel = UILabel()
        longTitleLabel.text = "Speechly"
        longTitleLabel.textColor = UIColor.white
        //longTitleLabel.font = UIFont(name: "Futura", size: 20)
        //longTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        longTitleLabel.font = UIFont.italicSystemFont(ofSize: 20)
            longTitleLabel.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let texto = items[indexPath.section][indexPath.row]
        // "On a Date","Making Friends"],["General","Medical School","Law School"],["Police Interrogation","Meeting the Parents","Zombie Apocolypse"]
        
        if texto == "On a Date" {
            selectedQuestions = allQuestions.date
        } else if texto == "Making Friends" {
            selectedQuestions = allQuestions.friends
        } else if texto == "General" {
            selectedQuestions = allQuestions.interview
        } else if texto == "Unusual" {
            selectedQuestions = allQuestions.criticalThinking
        } else if texto == "Engineering" {
            selectedQuestions = allQuestions.engineering
        } else if texto == "Medical School" {
            selectedQuestions = allQuestions.medicalSchool
        } else if texto == "Lawyer" {
            selectedQuestions = allQuestions.lawyer
        } else if texto == "Sales" {
            selectedQuestions = allQuestions.sales
        } else if texto == "Nursing" {
            selectedQuestions = allQuestions.nursing
        } else if texto == "Accounting" {
            selectedQuestions = allQuestions.accounting
        } else if texto == "Marketing" {
            selectedQuestions = allQuestions.marketing
        } else if texto == "Software Engineering" {
            selectedQuestions = allQuestions.programming
        } else {
            print("NOT FOUND")
        }
        categoryTitle = texto
        self.performSegue(withIdentifier: "menuToExercise", sender: self)

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectiono.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectiono[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        
        cell.menuLabel?.text = self.items[indexPath.section][indexPath.row]
        
        return cell
    }
    
}

