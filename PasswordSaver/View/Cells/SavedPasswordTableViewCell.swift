//
//  SavedPasswordTableViewCell.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class SavedPasswordTableViewCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var email: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        logo.image = #imageLiteral(resourceName: "defaultSiteImageSmall")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        logo.image = #imageLiteral(resourceName: "defaultSiteImageSmall")
        url.text = ""
        email.text = ""
    }

}
