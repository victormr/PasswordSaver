//
//  ViewController.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 01/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var keepConnected: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordBottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.navigationController?.isNavigationBarHidden = true
        passwordTextField.delegate = self
        userTextField.delegate = self
        loginButton.cornerRadius = 25
        
        setKeyboardAvoidance(scrollView: self.scrollView)
    }
    
    func doLogin(withPassword password: String) {
        let service = LoginService()
        startLoading()
        service.login(user: userTextField.text!, password: password, withCompletionHandler: { afResponse in
            self.stopLoading()
            guard let response = afResponse.response else {
                // erro inesperado
                self.error(withMessage: "Ocorreu um erro inesperado, tente novamente mais tarde")
                return
            }
            
            if response.statusCode == 403 {
                //tratar para email/senha incorreta
                self.error(withMessage: "Email/Senha incorreto(s)")
                return
            }
            else if response.statusCode == 400 {
                //tratar para email invalido
                self.error(withMessage: "Email inválido")
                return
            }
            
            if let json = afResponse.result.value {
                if let dictionary = json as? [String: String] {
                    UserInfoModel.authorizationToken = dictionary["token"]!
                    UserInfoModel.loggedUser = self.userTextField.text!
                    
                    let user = UserInfoModel()
                    user.user = self.userTextField.text!
                    user.password = self.passwordTextField.text!
                    
                    if let savedInfo = Keychain.get(key: self.userTextField.text!) {
                        let oldInfo = SavedPasswordListModel(fromString: savedInfo)
                        user.haveTouchID = oldInfo.user.haveTouchID
                        if user.password.isEmpty {
                            user.password = oldInfo.user.password
                        }
                        oldInfo.user = user
                        
                        Keychain.set(key: self.userTextField.text!, value: oldInfo.toString())
                    }
                    else {
                        let savedInfo = SavedPasswordListModel()
                        savedInfo.user = user
                        savedInfo.setPasswords([SavedPasswordModel]()) 
                        
                        Keychain.set(key: self.userTextField.text!, value: savedInfo.toString())
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    func error(withMessage: String) {
        errorLabel.text = withMessage
        errorLabel.isHidden = false
        
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissErrorLAbel), userInfo: nil, repeats: false)
    }
    
    @objc func dismissErrorLAbel() {
        errorLabel.isHidden = true
    }
    
    func setUserDefaults() {
        DispatchQueue.main.async {
            if self.keepConnected.isOn {
                let keepConnected: String = self.userTextField.text ?? ""
                UserDefaults.standard.set(keepConnected, forKey: "keepConnected")
            } else {
                UserDefaults.standard.set("", forKey: "keepConnected")
            }
        }
    }
    
    @IBAction func loginButtonTouchUpInside(_ sender: RoundedButton) {
        setUserDefaults()
        doLogin(withPassword: passwordTextField.text!)
    }
    
    
    @IBAction func goToRegister(_ sender: UIButton) {
        self.performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerSegue" {
            if let destinationVC = segue.destination as? UserRegisterViewController{
                destinationVC.delegate = self
                destinationVC.transitioningDelegate = self
            }
        }
    }
    
    func getTouchID(forUser user: UserInfoModel) {
        let myContext = LAContext()
        let myLocalizedReasonString = "Use para logar novamente"
        
        var authError: NSError?
        if #available(iOS 8.0, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    if success {
                        self.setUserDefaults()
                        self.doLogin(withPassword: user.password)
                    } else {
                        DispatchQueue.main.async {
                            self.passwordTextField.becomeFirstResponder()
                            self.passwordTextField.isHidden = false
                            self.passwordBottomView.isHidden = false
                        }
                    }
                }
            }
        }
    }
}

extension LoginViewController: UserRegisterDelegate {
    func didRegistered() {
        self.dismiss(animated: false, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.userTextField {
            self.passwordTextField.isHidden = true
            self.passwordTextField.text! = ""
            self.passwordBottomView.isHidden = true
        }
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.userTextField && string == "\n" {
            textField.endEditing(true)
            guard let userString = Keychain.get(key: self.userTextField.text!) else {
                self.passwordTextField.becomeFirstResponder()
                self.passwordTextField.isHidden = false
                self.passwordBottomView.isHidden = false
                return true
            }
            let savedPassword = SavedPasswordListModel(fromString: userString)
            if savedPassword.user.haveTouchID != nil && savedPassword.user.haveTouchID == true {
                setUserDefaults()
                getTouchID(forUser: savedPassword.user)
                return false
            }
            else {
                self.passwordTextField.becomeFirstResponder()
                self.passwordTextField.isHidden = false
                self.passwordBottomView.isHidden = false
            }
        }
        return true
    }
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return ModalAnimation(showing: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ModalAnimation(showing: false)
    }
}

