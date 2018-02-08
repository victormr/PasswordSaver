//
//  RoundedButton.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set (newRadius) {
            self.layer.cornerRadius = newRadius
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 20
    }
    
}
