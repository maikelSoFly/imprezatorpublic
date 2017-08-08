//
//  TableViewCell.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var checkBox: CheckBoxView!
    @IBOutlet weak var lblCash: UILabel!
    
    var key: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected stat
        
    }
    
    func configure(seller: Seller) {
        if seller.isChecked {
            self.checkBox.markAsChecked()
            //self.backgroundColor = UIColor.init(red: 40/255, green: 40/255, blue: 40/255, alpha: 255)
        }
        else {
            self.checkBox.markAsUnChecked()
            //self.backgroundColor = UIColor.black
        }
        
        self.lblName?.text = seller.email
        self.lblCash?.text = "\(String(describing: seller.sum)) PLN"
        
        self.checkBox?.checkBoxChanged = {
            
            if seller.isChecked {
                self.checkBox?.markAsChecked()
                checkedCounter += 1
                
                //self.backgroundColor = UIColor.init(red: 40/255, green: 40/255, blue: 40/255, alpha: 255)
                seller.isChecked = true
            }
            else {
                self.checkBox?.markAsUnChecked()
                checkedCounter -= 1
                
                //self.backgroundColor = UIColor.black
                seller.isChecked = false
            }
        }
    }
    
    
    //    func configure(guest: Guest) {
    //
    //        if guest.isChecked! {
    //            self.checkBox.markAsChecked()
    //            //self.backgroundColor = UIColor.init(red: 40/255, green: 40/255, blue: 40/255, alpha: 255)
    //        }
    //        else {
    //            self.checkBox.markAsUnChecked()
    //            //self.backgroundColor = UIColor.black
    //        }
    //
    //        self.lblName?.text = guest.name
    //
    //        self.checkBox?.checkBoxChanged = {
    //
    //            if !guest.isChecked! {
    //                self.checkBox?.markAsChecked()
    //                checkedCounter += 1
    //
    //                //self.backgroundColor = UIColor.init(red: 40/255, green: 40/255, blue: 40/255, alpha: 255)
    //                guest.isChecked = true
    //            }
    //            else {
    //                self.checkBox?.markAsUnChecked()
    //                checkedCounter -= 1
    //
    //                //self.backgroundColor = UIColor.black
    //                guest.isChecked = false
    //            }
    //        }
    //    }
}

