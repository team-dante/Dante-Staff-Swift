//
//  PatientTableViewCell.swift
//  Dante Staff
//
//  Created by Hung Phan on 8/29/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {

    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var patientPhoneNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
