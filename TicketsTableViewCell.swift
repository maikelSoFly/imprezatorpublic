//
//  TicketsTableViewCell.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

protocol TicketsCellDelegate {
    func setPrice(price: Double, cell: TicketsTableViewCell)
    func setQuantity(quantity: Int, cell: TicketsTableViewCell)
    func editingDidEnd()
}

class TicketsTableViewCell: UITableViewCell {
    
    var delegate: TicketsCellDelegate? = nil
    
    @IBOutlet weak var tfPrice: UITextField!
    
    @IBOutlet weak var tfQuantity: UITextField!
    @IBAction func handleBtnPlus(_ sender: UIButton) {
        self.quantity += 1
        tickets?.quantity = quantity
        if tfQuantity.isEditing {
            tfQuantity.text = String(quantity)
        } else {
            tfQuantity.text = "⨯ " + String(quantity)
        }
        delegate?.editingDidEnd()
    }
    @IBAction func handleBtnMinus(_ sender: UIButton) {
        if quantity > 0 {
            quantity -= 1
            delegate?.setQuantity(quantity: quantity, cell: self)
            tickets?.quantity = quantity
        }
        if tfQuantity.isEditing {
            tfQuantity.text = String(quantity)
        } else {
            tfQuantity.text = "⨯ " + String(quantity)
        }
        delegate?.editingDidEnd()
    }
    
    
    @IBAction func editingEndQuantity(_ sender: UITextField) {
       
        if let tmpQuantity = sender.text?.intValue {
            quantity = tmpQuantity
            sender.text = "⨯ \(sender.text!)"
            delegate?.editingDidEnd()
        }
    }
    
    @IBAction func editingEndPrice(_ sender: UITextField) {
        delegate?.editingDidEnd()
    }
    
    
    
    
    //    @IBAction func handleValueChangePrice(_ sender: UITextField) {
    //        delegate?.editingDidEnd()
    //    }
    //    @IBAction func handleValueChangeQuantity(_ sender: UITextField) {
    //        delegate?.editingDidEnd()
    //    }
    
    
    @IBAction func editingBeginQuantity(_ sender: UITextField) {
        sender.text = ""
    }
    
    @IBAction func editingBeginPrice(_ sender: UITextField) {
        sender.text = ""
    }
    
    
    
    var price: Int = 0
    var quantity: Int = 0
    var tickets: Tickets? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tfQuantity.addTarget(self, action: #selector(TicketsTableViewCell.tfQuantityEditingChanged), for: UIControlEvents.editingChanged)
        tfPrice.addTarget(self, action: #selector(TicketsTableViewCell.tfPriceEditingChanged), for: UIControlEvents.editingChanged)
    }
    
    
    @objc func tfQuantityEditingChanged() {
        quantity = (tfQuantity.text?.intValue)!
        delegate?.setQuantity(quantity: quantity, cell: self)
        tickets?.quantity = quantity
        // delegate?.editingDidEnd()
    }
    
    @objc func tfPriceEditingChanged() {
        price = (tfPrice.text?.intValue)!
        tickets?.price = price
        // delegate?.editingDidEnd()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(tickets: Tickets) {
        self.tickets = tickets
        
        self.quantity = tickets.quantity
        self.price = tickets.price
        tfQuantity.text = "⨯ \(String(self.quantity))"
        tfPrice.text = String(self.price)
    }
    
}

