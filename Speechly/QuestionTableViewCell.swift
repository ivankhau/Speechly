//
//  QuestionTableViewCell.swift
//  speechdojo
//
//  Created by Ivan Khau on 3/20/17.
//  Copyright © 2017 Ivan Khau. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var numberLabel: UILabel!

    @IBOutlet weak var questionLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
