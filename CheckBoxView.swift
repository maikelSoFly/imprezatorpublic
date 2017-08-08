//
//  CheckBoxView.swift
//  Imprezator
//
//  Created by Mikołaj Stępniewski on 08.08.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import AudioToolbox

protocol CheckDelegate {
    func didCheck()
}

class CheckBoxView: UIView {
    var isChecked: Bool
    var checkBoxImageView: UIImageView
    var checkBoxChanged: () -> () = { }
    
    var delegate:CheckDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        self.isChecked = false
        self.checkBoxImageView = UIImageView(image: nil)
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    func setup() {
        //Border
        //self.layer.borderWidth = 1.0
        self.isUserInteractionEnabled = true
        
        self.checkBoxImageView.frame = CGRect(x: 2, y: 2, width: 25, height: 25)
        self.addSubview(self.checkBoxImageView)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state == UIGestureRecognizerState.began {
            self.checkBoxChanged()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didCheck()
        }
    }
    
    func markAsChecked() {
        self.checkBoxImageView.image = UIImage(named: "small-dot")
    }
    
    func markAsUnChecked() {
        self.checkBoxImageView.image = UIImage(named: "empty-dot")
    }
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

