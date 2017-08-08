//
//  Seller.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class Seller: NSObject {
    var sum: NSNumber
    var email: String
    var name: String
    var isChecked: Bool
    var paymentDetails: [CFNumber : CFNumber]
    var key: String
    var timestamp: String = ""
    
    init(email: String, name: String, sum: NSNumber, isChecked: Bool, paymentDetails: [CFNumber : CFNumber], key: String) {
        self.email = email
        self.sum = sum
        self.name = name
        self.paymentDetails = paymentDetails
        self.isChecked = isChecked
        self.key = key
    }
}

