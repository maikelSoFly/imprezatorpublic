//
//  PaymentDetailsTableViewCell.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class PaymentDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(price: CFNumber, quantity: CFNumber) {
        self.lblPrice.text = "\(String(describing: price)) PLN"
        self.lblQuantity.text = "⨯ \(String(describing: quantity))"
    }
    
}

