//
//  ButtonTableViewCell.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 02/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

protocol ButtonTableViewCellDelegate {
    func buttonTouchUpInside(cell:ButtonTableViewCell)
}

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    var delegate: ButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        delegate?.buttonTouchUpInside(cell: self)
    }
    
}
