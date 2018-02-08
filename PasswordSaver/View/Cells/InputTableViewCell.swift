//
//  InputTableViewCell.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 02/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

protocol InputTableViewCellDelegate {
    func inputTextChanged(cell:InputTableViewCell, text: String)
}

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    var delegate: InputTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        input.delegate = self
        input.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        input.text = ""
        errorMessage.isHidden = true
    }
    
}

extension InputTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var afterChange = textField.text!
        
        if string.isEmpty {
            let subStringValue = afterChange[..<afterChange.index(before: afterChange.endIndex)]
            afterChange = String(subStringValue)
        } else {
            afterChange += string
        }
        
        self.delegate?.inputTextChanged(cell: self, text: afterChange)

        return true
    }
}
