//
//  PatientPinTableViewCell.swift
//  Dante Staff
//
//  Created by Xinhao Liang on 9/9/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class PatientPinTableViewCell: UITableViewCell {

    @IBOutlet weak var patientLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
