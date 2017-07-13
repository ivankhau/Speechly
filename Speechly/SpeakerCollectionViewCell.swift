//
//  SpeakerCollectionViewCell.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/20/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import UIKit

class SpeakerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var speakerLabel: UILabel!
    
    @IBOutlet weak var speakerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        isSelected = false
    }
    
    
}
