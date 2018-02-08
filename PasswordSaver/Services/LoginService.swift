//
//  LoginService.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit
import Alamofire
import Moya

class LoginService {

    func login(user: String, password: String, withCompletionHandler: @escaping (_ response: DataResponse<Any>) -> Void) {
        
        let parameters: Parameters = [
            "email": user,
            "password": password
        ]
        
        let headers: HTTPHeaders = [
            "content-type": "application/json"
        ]
        
        Alamofire.request("https://dev.people.com.ai/mobile/api/v2/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            withCompletionHandler(response)
        })
    }
}
