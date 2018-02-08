//
//  BaseViewController.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 06/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController{

    let activityIndicator = UIActivityIndicatorView()
    var hudView = UIView()
    var scrollViewToAvoidance = UIScrollView()
    
    func startLoading() {
        hudView = UIView(frame: self.view.frame)
        hudView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        hudView.addSubview(activityIndicator)
        activityIndicator.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 0, height: 0)
        hudView.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        self.view.addSubview(hudView)
        self.view.bringSubview(toFront: hudView)
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        self.hudView.removeFromSuperview()
    }
    
    func setKeyboardAvoidance(scrollView: UIScrollView) {
        scrollViewToAvoidance = scrollView
        scrollView.keyboardDismissMode = .interactive
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowWithNotification), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideWithNotification), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShowWithNotification(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let bottomInset = keyboardFrame.height != 0 ? keyboardFrame.height + 20 : 0
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollViewToAvoidance.contentInset = UIEdgeInsets(top: self.scrollViewToAvoidance.contentInset.top,
                                                        left: self.scrollViewToAvoidance.contentInset.left,
                                                        bottom: bottomInset,
                                                        right: self.scrollViewToAvoidance.contentInset.right)
        })
    }
    @objc func keyboardWillHideWithNotification(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollViewToAvoidance.contentInset = UIEdgeInsets(top: self.scrollViewToAvoidance.contentInset.top,
                                                        left: self.scrollViewToAvoidance.contentInset.left,
                                                        bottom: 0,
                                                        right: self.scrollViewToAvoidance.contentInset.right)
        })
    }

}
