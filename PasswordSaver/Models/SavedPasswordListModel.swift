//
//  SavedPasswordListModel.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 04/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class SavedPasswordListModel: Codable {
    
    private var passwords = [SavedPasswordModel]()
    var user = UserInfoModel()
    private var maxIndex:Int = 0
    
    init() {
        self.passwords = [SavedPasswordModel]()
        self.user = UserInfoModel()
        self.maxIndex = 0
    }
    
    init(fromString: String) {
        do {
            let data : Data = fromString.data(using: String.Encoding.utf8)!
            let object = try JSONDecoder().decode(SavedPasswordListModel.self, from: data)
            
            self.user = object.user
            self.passwords = object.passwords
            self.maxIndex = object.maxIndex
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
    
    func setPasswords(_ newPasswords:[SavedPasswordModel] ) {
        self.passwords = newPasswords
    }
    
    func getPasswords() -> [SavedPasswordModel] {
        return self.passwords
    }
    
    func addToPasswords(value: SavedPasswordModel) {
        maxIndex += 1
        value.index = self.maxIndex
        passwords.append(value)
    }
    
    func deleteFromPasswords(value: SavedPasswordModel) {
        var index = 0
        for password in passwords {
            if password.index == value.index {
                passwords.remove(at: index)
            }
            index += 1
        }
    }
    
    func updateFromPasswords(newValue: SavedPasswordModel) {
        var index = 0
        for password in passwords {
            if password.index == newValue.index {
                passwords[index] = newValue
            }
            index += 1
        }
    }
    
    func getPasswordWithIndex(Index index: Int) ->SavedPasswordModel? {
        for password in passwords {
            if password.index == index {
                return password
            }
        }
        return nil
    }

}
