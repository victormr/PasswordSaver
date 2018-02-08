//
//  UserInfoModel.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class UserInfoModel: Codable {

    static var authorizationToken = ""
    static var loggedUser: String = ""
    
    var user: String = ""
    var password: String = ""
    var haveTouchID:Bool?
    
    init() {
        self.user = ""
        self.password = ""
    }
    
    init(fromString: String) {
        do {
            let data : Data = fromString.data(using: String.Encoding.utf8)!
            let object = try JSONDecoder().decode(UserInfoModel.self, from: data)
            
            self.user = object.user
            self.password = object.password
            self.haveTouchID = object.haveTouchID
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
    
}
