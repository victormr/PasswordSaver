//
//  SavedPasswordListModelTests.swift
//  PasswordSaverTests
//
//  Created by Victor Martins Rabelo on 05/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import XCTest
@testable import PasswordSaver

class SavedPasswordListModelTests: XCTestCase {
        
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitFromString() {
        let string = "{\"maxIndex\":1,\"user\":{\"haveTouchID\":true,\"user\":\"teste@teste.com\",\"password\":\"asd123ASD#\"},\"passwords\":[{\"user\":\"asd\",\"password\":\"asd\",\"index\":1,\"url\":\"google.com\",\"logo\":\"\"}]}"

        let saved = SavedPasswordListModel(fromString: string)

        XCTAssertTrue(saved.user.user == "teste@teste.com", "Erro ao transformar o usuario")
        XCTAssertTrue(saved.user.password == "asd123ASD#", "Erro ao transformar a senha")
        XCTAssertTrue(saved.user.haveTouchID == true, "Erro ao transformar o haveTouchID")
        let passwords = saved.getPasswords()
        XCTAssertTrue(passwords[0].user == "asd", "Erro ao transformar o usuario do site")
        XCTAssertTrue(passwords[0].password == "asd", "Erro ao transformar a senha do site")
        XCTAssertTrue(passwords[0].index == 1, "Erro ao transformar o index do site")
        XCTAssertTrue(passwords[0].url == "google.com", "Erro ao transformar a url do site")
    }
    
    func tesToString() {
        let user = UserInfoModel()
        user.user = "teste@teste.com"
        user.password = "asd123ASD#"
        user.haveTouchID = true
        
        let password = SavedPasswordModel()
        password.user = "asd"
        password.password = "asd"
        password.index = 1
        password.url = "google.com"
        
        let list = SavedPasswordListModel()
        list.user = user
        list.addToPasswords(value: password)
        
        let string = list.toString()
        let stringRef = "{\"maxIndex\":1,\"user\":{\"haveTouchID\":true,\"user\":\"teste@teste.com\",\"password\":\"asd123ASD#\"},\"passwords\":[{\"password\":\"asd\",\"index\":1,\"url\":\"google.com\",\"user\":\"asd\"}]}"
        XCTAssertTrue(string == stringRef, "Erro ao transformar objeto para string")
    }
    
    func testSetAndGetPasswords() {
        var passwords = [SavedPasswordModel]()
        
        var index = 0
        for _ in 0...5 {
            let password = SavedPasswordModel()
            password.user = String(index)
            password.password = String(index)
            password.index = index
            password.url = String(index)
            
            passwords.append(password)
            index += 1
        }
        
        let list = SavedPasswordListModel()
        list.setPasswords(passwords)
        
        index = 0
        for item in list.getPasswords() {
            XCTAssertTrue(item.user == String(index))
            XCTAssertTrue(item.password == String(index))
            XCTAssertTrue(item.index == index)
            XCTAssertTrue(item.url == String(index))
            
            index += 1
        }
    }
    
    func testAddToPasswords() {
        let list = SavedPasswordListModel()
        
        let password = SavedPasswordModel()
        password.user = "user"
        password.password = "password"
        password.url = "url"
        
        list.addToPasswords(value: password)
        
        var passwords = list.getPasswords()
        XCTAssertTrue(passwords[0].user == "user")
        XCTAssertTrue(passwords[0].password == "password")
        XCTAssertTrue(passwords[0].url == "url")
        XCTAssertTrue(passwords[0].index == 1)
    }
    
    func testDeleteFromPasswords() {
        var passwords = [SavedPasswordModel]()
        
        var index = 0
        for _ in 0...5 {
            let password = SavedPasswordModel()
            password.user = String(index)
            password.password = String(index)
            password.index = index
            password.url = String(index)
            
            passwords.append(password)
            index += 1
        }
        
        let list = SavedPasswordListModel()
        list.setPasswords(passwords)
        
        let passwordDeleted = SavedPasswordModel()
        passwordDeleted.user = String(index)
        passwordDeleted.password = String(index)
        passwordDeleted.index = 3
        passwordDeleted.url = String(index)
        
        list.deleteFromPasswords(value: passwordDeleted)
        
        for item in list.getPasswords() {
            XCTAssertTrue(item.index != 3)
        }
        XCTAssertTrue(list.getPasswords().count == 5)
    }
    
    func testUpdateFromPasswords() {
        var passwords = [SavedPasswordModel]()
        
        var index = 0
        for _ in 0...5 {
            let password = SavedPasswordModel()
            password.user = String(index)
            password.password = String(index)
            password.index = index
            password.url = String(index)
            
            passwords.append(password)
            index += 1
        }
        
        let list = SavedPasswordListModel()
        list.setPasswords(passwords)
        
        let passwordNewValues = SavedPasswordModel()
        passwordNewValues.user = "userNew"
        passwordNewValues.password = "passwordNew"
        passwordNewValues.index = 3
        passwordNewValues.url = "urlNew"
        
        list.updateFromPasswords(newValue: passwordNewValues)
        let newValue = list.getPasswordWithIndex(Index: 3)
        XCTAssertTrue(newValue?.url == "urlNew")
        XCTAssertTrue(newValue?.password == "passwordNew")
        XCTAssertTrue(newValue?.user == "userNew")
        XCTAssertTrue(newValue?.index == 3)
    }
    
    func testGetPasswordWithIndex() {
        var passwords = [SavedPasswordModel]()
        
        var index = 0
        for _ in 0...5 {
            let password = SavedPasswordModel()
            password.user = String(index)
            password.password = String(index)
            password.index = index
            password.url = String(index)
            
            passwords.append(password)
            index += 1
        }
        
        let list = SavedPasswordListModel()
        list.setPasswords(passwords)
        
        let newValue = list.getPasswordWithIndex(Index: 3)
        XCTAssertTrue(newValue?.url == "3")
        XCTAssertTrue(newValue?.password == "3")
        XCTAssertTrue(newValue?.user == "3")
        XCTAssertTrue(newValue?.index == 3)
    }
    
    func testTeste() {
        
        print("asdasd")
    }
}

