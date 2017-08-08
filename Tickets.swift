//
//  Tickets.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class Tickets: NSObject {
    var price: Int
    var quantity: Int
    
    init(price: Int, quantity: Int) {
        self.price = price
        self.quantity = quantity
    }
}

