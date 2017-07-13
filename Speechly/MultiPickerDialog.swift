//
//  MultiPickerDialog.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/12/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import ObjectiveC

/* Implication Example
 let pickerData : [[String:String]] = [
 [
 "value":"en",
 "display":"General"
 ],
 [
 "value":"ar",
 "display":"Med School"
 ],
 [
 "value":"fr",
 "display":"Law School"
 ]
 ]
 
 MultiPickerDialog().show(title: "Question Types",doneButtonTitle:"Begin", cancelButtonTitle:"Cancel" ,options: pickerData, selected:  self.selectedIDs) {
 values -> Void in
 //print("SELECTED \(value), \(showName)")
 print("callBack \(values)")
 var finalText = ""
 self.selectedIDs.removeAll()
 for (index,value) in values.enumerated(){
 self.selectedIDs.append(value["value"]!)
 finalText = finalText  + value["display"]! + (index < values.count - 1 ? " , ": "")
 }
 
 //sender?.titleLabel?.text = finalText
 }*/


class MultiPickerDialog: UIView, UITableViewDelegate, UITableViewDataSource {
    
    typealias MultiPickerCallback = (_ values: [[String: String]]) -> Void
    
    /* Constants */
    private let kPickerDialogDefaultButtonHeight:       CGFloat = 50
    private let kPickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kPickerDialogCornerRadius:              CGFloat = 7
    private let kPickerDialogDoneButtonTag:             Int     = 1
    
    /* Views */
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    private var picker:       UITableView!
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!
    
    /* Variables */
    private var pickerData =         [[String: String]]()
    private var selectedPickerValues: [String]?
    private var callback:            MultiPickerCallback?
    
    /* Added Settings */
    private var doneButtonHidden: Bool = false
    private var cancelButtonHidden: Bool = false
    
    
    /* Overrides */
    init() {
        super.init(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height))
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.dialogView = createContainerView()
        
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        picker.delegate = self
        picker.dataSource = self
        picker.allowsMultipleSelection = true
        
        
        /*
         NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:0 inSection:0];
         [self tableView:tableViewList didSelectRowAtIndexPath:selectedCellIndexPath];
         [tableViewList selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
         */
        
        self.addSubview(self.dialogView!)
        
        
    }
    
    /* Handle device orientation changes */
    func deviceOrientationDidChange(notification: NSNotification) {
        close() // For now just close it
    }
    
    /* Helper to find row of selected value */
    func findIndicesForValues(values: [String], array: [[String: String]]) -> [Int] {
        var selectedIndices : [Int] = []
        for (index, dictionary) in array.enumerated() {
            for selectedOption in values {
                if dictionary["value"] == selectedOption {
                    selectedIndices.append(index)
                }
            }
            
        }
        return selectedIndices
    }
    
    /* Create the dialog view, and animate opening the dialog */
    func show(title: String, setDoneButtonHidden: Bool = false, setCancelButtonHidden: Bool = false, doneButtonTitle: String = "Select", cancelButtonTitle: String = "Cancel", options: [[String: String]], selected: [String]? = nil, callback: @escaping MultiPickerCallback) {
        
        cancelButtonHidden = false
        doneButtonHidden = false
        
        if setDoneButtonHidden == true {
            doneButtonHidden = true
        } else {
            doneButtonHidden = false
        }
        
        if setCancelButtonHidden == true {
            cancelButtonHidden = true
        } else {
            cancelButtonHidden = false
        }
        
        self.titleLabel.text = title
        self.pickerData = options
        //self.doneButton.setTitle(doneButtonTitle, for: .normal)
        self.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        self.callback = callback
        
        if selected != nil {
            self.selectedPickerValues = selected
            let selectedIndices = findIndicesForValues(values: selected!, array: options)
            print("selectedIndices \(selectedIndices)")
            for index in selectedIndices{
                //let selectedCellIndexPath = NSIndexPath(forRow: index, inSection: 0)
                let selectedCellIndexPath = NSIndexPath(row: index, section: 0)
                //self.tableView(
                self.tableView(picker, didSelectRowAt: selectedCellIndexPath as IndexPath)
                //self.tableView(tableView: picker, didSelectRowAtindexPath: selectedCellIndexPath)
                //self.tableView(tableView: picker, didSelectRowAtIndexPath: selectedCellIndexPath)
                picker.selectRow(at: selectedCellIndexPath as IndexPath, animated: true, scrollPosition: .none)
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(self)
        appDelegate.window?.bringSubview(toFront: self)
        appDelegate.window?.endEditing(true)
        
        
        //NotificationCenter.defaultCenter.addObserver(self, selector: #selector(MultiPickerDialog.deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
        },
            completion: nil
        )
    }
    
    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        NotificationCenter.default.removeObserver(self)
        
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [],
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
        }) { (finished: Bool) -> Void in
            for v in self.subviews {
                v.removeFromSuperview()
            }
            
            self.removeFromSuperview()
        }
    }
    
    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSize(width: 300.0, height: 230
            + kPickerDialogDefaultButtonHeight
            + kPickerDialogDefaultButtonSpacerHeight)
        
        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
                           UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
                           UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]
        
        let cornerRadius = kPickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).cgPath
        
        // There is a line above the button
        let lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - kPickerDialogDefaultButtonHeight - kPickerDialogDefaultButtonSpacerHeight, width: dialogContainer.bounds.size.width, height: kPickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ
        
        //Title
        self.titleLabel = UILabel(frame: CGRect(x:10, y:10, width:280, height:30))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = UIColor(hex: 0x333333)
        self.titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        dialogContainer.addSubview(self.titleLabel)
        
        self.picker = UITableView(frame: CGRect(x:0, y:30,width:100, height:100))
        //self.picker.setValue(UIColor(hex: 0x333333), forKeyPath: "textColor")
        self.picker.autoresizingMask = UIViewAutoresizing.flexibleRightMargin
        self.picker.frame.size.width = 300
        self.picker.frame.size.height = 200
        self.picker.backgroundColor = UIColor.clear
        dialogContainer.addSubview(self.picker)
        
        // Add the buttons
        addButtonsToView(container: dialogContainer)
        
        return dialogContainer
    }
    
    /* Add buttons to container */
    private func addButtonsToView(container: UIView) {
        
        let buttonWidth = container.bounds.size.width
        if cancelButtonHidden != true && doneButtonHidden != true {
            //buttonWidth = container.bounds.size.width / 2
        }
        
        if cancelButtonHidden == false {
            
            self.cancelButton = UIButton(type: UIButtonType.custom) as UIButton
            self.cancelButton.frame = CGRect(
                x:0,
                y:container.bounds.size.height - kPickerDialogDefaultButtonHeight,
                width:buttonWidth,
                height:kPickerDialogDefaultButtonHeight
            )
            self.cancelButton.setTitleColor(UIColor(hex: 0x555555), for: UIControlState.normal)
            self.cancelButton.setTitleColor(UIColor(hex: 0x555555), for: UIControlState.highlighted)
            self.cancelButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 15)
            self.cancelButton.layer.cornerRadius = kPickerDialogCornerRadius
            self.cancelButton.addTarget(self, action: #selector(MultiPickerDialog.buttonTapped), for: UIControlEvents.touchUpInside)
            container.addSubview(self.cancelButton)
        
        }
        
        /*if doneButtonHidden == false {
            
            self.doneButton = UIButton(type: UIButtonType.custom) as UIButton
            self.doneButton.frame = CGRect(
                x: buttonWidth,
                y: container.bounds.size.height - kPickerDialogDefaultButtonHeight,
                width: buttonWidth,
                height: kPickerDialogDefaultButtonHeight
            )
            self.doneButton.tag = kPickerDialogDoneButtonTag
            self.doneButton.setTitleColor(UIColor(hex: 0x555555), for: UIControlState.normal)
            self.doneButton.setTitleColor(UIColor(hex: 0x555555), for: UIControlState.highlighted)
            self.doneButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 15)
            self.doneButton.layer.cornerRadius = kPickerDialogCornerRadius
            self.doneButton.addTarget(self, action: #selector(MultiPickerDialog.buttonTapped), for: UIControlEvents.touchUpInside)
            container.addSubview(self.doneButton)
            
        }*/
        
        
    }
    
    func buttonTapped(sender: UIButton!) {
        if sender.tag == kPickerDialogDoneButtonTag {
            var theSelectedValues : [[String: String]] = []
            
            if let indexPathsForSelectedRows = self.picker.indexPathsForSelectedRows{
                for indexPath  in indexPathsForSelectedRows{
                    let cell = self.picker.cellForRow(at: indexPath)
                    theSelectedValues.append(["value":(cell?.contnetIdentifier)!, "display":(cell?.textLabel?.text)!])
                    
                }
            }
            
            self.callback?(theSelectedValues)
        }
        
        close()
    }
    
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    /* Helper function: count and return the screen's size */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell =  tableView.dequeueReusableCell(withIdentifier: "cell")
        if ((cell == nil)) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        let theCell = cell!
        
        theCell.textLabel?.text = self.pickerData[indexPath.row]["display"]
        theCell.contnetIdentifier = self.pickerData[indexPath.row]["value"]
        theCell.textLabel?.textAlignment = .left
        theCell.backgroundColor = UIColor.clear
        theCell.selectionStyle = .none
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath as IndexPath)
        theCell.accessoryType = rowIsSelected ? .checkmark : .none
        
        
        return theCell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pickerData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell = self.picker.cellForRow(at: indexPath)
        selectedDialogOption = cell?.textLabel?.text!
        print(selectedDialogOption!)
        
        close()
        
        //tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        //tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
}

var AssociatedObjectHandleOfCellContnetIdentifier: UInt8 = 0

extension UITableViewCell {
    var contnetIdentifier:String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandleOfCellContnetIdentifier) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandleOfCellContnetIdentifier, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: Float = 1.0){
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
    
}
