//
//  EventTableViewCell.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    var key: String = ""
    var name: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(key: String, name: String) {
        self.key = key
        self.name = name
    }
    
}

