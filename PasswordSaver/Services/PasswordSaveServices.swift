//
//  PasswordSaveServices.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit
import Alamofire

class PasswordSaveServices {

    public func downloadLogo(forUrl:String, withCompletionHandler: @escaping (_ image: UIImage) -> Void) {
        let auth = UserInfoModel.authorizationToken
        let headers: HTTPHeaders = [
            "Authorization": auth
        ]
        
        Alamofire.request("https://dev.people.com.ai/mobile/api/v2/logo/\(forUrl)", headers: headers).responseData { response in
            if let data = response.result.value {
                if let image = UIImage(data: data) {
                    withCompletionHandler(image)
                }
            }
        }
    }
    
}
