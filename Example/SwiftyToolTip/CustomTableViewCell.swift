//
//  CustomTableViewCell.swift
//  SwiftyToolTip_Example
//
//  Created by Bob De Kort on 5/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var newImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.addToolTip(description: Description.Label.otherLabel, gesture: .longPress)
        newImageView.addToolTip(description: Description.ImageView.otherImageViews, gesture: .longPress)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
