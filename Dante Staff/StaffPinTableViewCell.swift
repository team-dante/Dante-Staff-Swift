//
//  StaffPinTableViewCell.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/12/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class StaffPinTableViewCell: UITableViewCell {

    @IBOutlet weak var staffLocation: UILabel!
    @IBOutlet weak var staffName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
