//
//  NewMenuTableViewCell.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/8/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class NewMenuTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var leftImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var rightImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIScreen.main.bounds.width == 414 {
            leftImageConstraint.constant = 192
            rightImageConstraint.constant = 192
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
