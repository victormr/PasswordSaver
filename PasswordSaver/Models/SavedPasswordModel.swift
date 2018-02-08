//
//  SavedPassword.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class SavedPasswordModel: Codable {
    
    private var logo: Data?
    var url: String = ""
    var user: String = ""
    var password: String = ""
    var index:Int = 0
    
    init() {
        self.logo = nil
        self.url = ""
        self.user = ""
        self.password = ""
        self.index = 0
    }
    
    init(fromString: String) {
        do {
            let data : Data = fromString.data(using: String.Encoding.utf8)!
            let object = try JSONDecoder().decode(SavedPasswordModel.self, from: data)
            
            self.user = object.user
            self.password = object.password
            self.url = object.url
            self.logo = object.logo
            self.index = object.index
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    func toString() -> String {
        var result = ""
        do {
            let jsonData = try JSONEncoder().encode(self)
            result = String(data:jsonData, encoding:.utf8)!
        } catch let error as NSError {
            print(error)
        }
        
        return result
    }
    
    func setLogo(image: UIImage) {
        logo = UIImagePNGRepresentation(image)!
    }
    
    func getLogo() -> UIImage {
        if let newLogo = logo {
            return UIImage(data: newLogo)!
        }
        return #imageLiteral(resourceName: "defaultSiteImagebig")
    }
    
}
