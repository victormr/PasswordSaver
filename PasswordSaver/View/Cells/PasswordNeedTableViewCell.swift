//
//  PasswordNeedTableViewCell.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class PasswordNeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var minimumSize: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var special: UILabel!
    @IBOutlet weak var letter: UILabel!
    @IBOutlet weak var upperCaseLetter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
