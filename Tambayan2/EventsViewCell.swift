//
//  EventsViewCell.swift
//  Tambayan2
//
//  Created by Rey Cerio on 2016-11-14.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit

class EventsViewCell: UITableViewCell {       //custom cell for the table
    
    @IBOutlet var imageViewCell: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
