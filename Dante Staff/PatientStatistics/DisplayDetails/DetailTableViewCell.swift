//
//  DetailTableViewCell.swift
//  Dante Staff
//
//  Created by Hung Phan on 9/1/19.
//  Copyright © 2019 Hung Phan. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var durationMinuteLabel: UILabel!
    @IBOutlet weak var timeline: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class CustomHeaderDetailTableViewCell : UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var leftHeaderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add separator to custom cell
//        let lineFrame = CGRect(x: 15, y: contentView.frame.size.height, width: contentView.frame.size.width, height: 1)
//        let line = UIView(frame: lineFrame)
//        line.backgroundColor = UIColor.white
//        addSubview(line)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
