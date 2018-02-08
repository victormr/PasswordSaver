//
//  RegisterServices.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit
import Alamofire

class RegisterServices {

    func register(user: String, password: String, name: String, withCompletionHandler: @escaping (_ response: DataResponse<Any>) -> Void) {
        
        let parameters: Parameters = [
            "email": user,
            "name": name,
            "password": password
        ]
        
        let headers: HTTPHeaders = [
            "content-type": "application/json"
        ]
        
        Alamofire.request("https://dev.people.com.ai/mobile/api/v2/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            withCompletionHandler(response)
        })
    }
    
}
