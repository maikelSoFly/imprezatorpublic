//
//  StringExtensions.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
    
}

extension String {
    var intValue: Int {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.intValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.intValue
            }
        }
        return 0
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

