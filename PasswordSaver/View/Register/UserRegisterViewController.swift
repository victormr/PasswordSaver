//
//  RegisterViewController.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 01/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

protocol UserRegisterDelegate {
    func didRegistered()
}

class UserRegisterViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    var delegate: UserRegisterDelegate?
    
    let formInputs = ["Nome", "Email", "Senha"];
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboardAvoidance(scrollView: self.scrollView)
    }

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func register() {
        let nameCell = getInputCellByName("Nome")
        let emailCell = getInputCellByName("Email")
        let passwordCell = getInputCellByName("Senha")
        
        let name = nameCell.input.text!
        let email = emailCell.input.text!
        let password = passwordCell.input.text!
        
        let service = RegisterServices()
        startLoading()
        service.register(user: email, password: password, name: name) { afResponse in
            self.stopLoading()
            guard let response = afResponse.response else {
                // erro inesperado
//                self.error(withMessage: "Ocorreu um erro inesperado, tente novamente mais tarde")
                return
            }
            
            if response.statusCode == 409 {
                self.handleServiceError(message: "Email já cadastrado")
                return
            }
            else if response.statusCode == 400 {
                self.handleServiceError(message: "Email inválido")
                return
            }
            
            if let json = afResponse.result.value {
                if let dictionary = json as? [String: String] {
                    UserInfoModel.authorizationToken = dictionary["token"]!
                    UserInfoModel.loggedUser = email
                    
                    let user = UserInfoModel()
                    user.user = email
                    user.password = password

                    let savedInfo = SavedPasswordListModel()
                    savedInfo.user = user
                    savedInfo.setPasswords([SavedPasswordModel]())
                    
                    Keychain.set(key: email, value: savedInfo.toString())
                    UserDefaults.standard.set(email, forKey: "keepConnected")
                    
                    self.dismiss(animated: true, completion: {
                        if let delegated = self.delegate {
                            delegated.didRegistered()
                        }
                    })
                }
            }
        }
    }
    
    func handleServiceError(message: String) {
        let emailCell = getInputCellByName("Email")
        
        emailCell.errorMessage.text = message
        emailCell.errorMessage.isHidden = false
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dismissValidateForm), userInfo: nil, repeats: false)
    }
}

extension UserRegisterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == formInputs.count {
            return 77
        } else if indexPath.row == formInputs.count + 1 {
            return 60
        }
        
        return UITableViewAutomaticDimension
    }
    
    func getInputCellByName(_ name:String) -> InputTableViewCell {
        guard let cell = tableView.cellForRow(at: IndexPath(item: formInputs.index(of: name)!, section: 0)) as? InputTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of InputTableViewCell.")
        }
        
        return cell
    }
}

extension UserRegisterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formInputs.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case formInputs.count + 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as? ButtonTableViewCell
                else {
                    fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")
            }
            cell.delegate = self
            
            return cell
        case formInputs.count:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "passwordNeedCell") as? PasswordNeedTableViewCell
                else {
                    fatalError("The dequeued cell is not an instance of PasswordNeedTableViewCell.")
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell") as? InputTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of InputTableViewCell.")
            }
            if indexPath.row == formInputs.index(of: "Senha") {
                cell.input.isSecureTextEntry = true
            }
            cell.input.placeholder = formInputs[indexPath.row]
            cell.delegate = self
            
            return cell
        }
    }
}

extension UserRegisterViewController: InputTableViewCellDelegate {
    func inputTextChanged(cell:InputTableViewCell, text: String) {
        let index = tableView.indexPath(for: cell)
        if index?.row == formInputs.index(of: "Senha") {
            let passwordNeedCell = tableView.cellForRow(at: IndexPath(item: index!.row + 1, section: 0)) as! PasswordNeedTableViewCell
            
            if text.isEmpty {
                passwordNeedCell.minimumSize.isHidden = false
                passwordNeedCell.number.isHidden = false
                passwordNeedCell.letter.isHidden = false
                passwordNeedCell.special.isHidden = false
                passwordNeedCell.upperCaseLetter.isHidden = false
            } else {
                let number = text.rangeOfCharacter(from: CharacterSet.decimalDigits)
                let lowercaseLetter = text.rangeOfCharacter(from: CharacterSet.lowercaseLetters)
                let special = text.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted)
                let upperCase = text.rangeOfCharacter(from: CharacterSet.uppercaseLetters)
    
                passwordNeedCell.minimumSize.isHidden = text.count >= 10
                passwordNeedCell.number.isHidden = number != nil ? true : false
                passwordNeedCell.letter.isHidden = lowercaseLetter != nil ? true : false
                passwordNeedCell.special.isHidden = special != nil ? true : false
                passwordNeedCell.upperCaseLetter.isHidden = upperCase != nil ? true : false
            }
        }
    }
}

extension UserRegisterViewController: ButtonTableViewCellDelegate {
    func buttonTouchUpInside(cell: ButtonTableViewCell) {
        validateForm()
    }
    
    func validateForm() {
        var isValidName = false
        var isValidEmail = false
        var isValidPassword = false
        
        let nameCell = getInputCellByName("Nome")
        let emailCell = getInputCellByName("Email")
        let passwordCell = getInputCellByName("Senha")
        
        nameCell.errorMessage.text = "Favor preencher o nome"
        emailCell.errorMessage.text = "Favor preencher o Email"
        
        if let name = nameCell.input.text {
            isValidName = name.count > 0
            nameCell.errorMessage.isHidden = isValidName
        }
        if let email = emailCell.input.text {
            isValidEmail = email.count > 0
            emailCell.errorMessage.isHidden = isValidEmail
        }
        if let password = passwordCell.input.text {
            let number = password.rangeOfCharacter(from: CharacterSet.decimalDigits)
            let lowercaseLetter = password.rangeOfCharacter(from: CharacterSet.lowercaseLetters)
            let special = password.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted)
            let upperCase = password.rangeOfCharacter(from: CharacterSet.uppercaseLetters)
            
            isValidPassword = password.count >= 10
            isValidPassword = isValidPassword && (number != nil ? true : false)
            isValidPassword = isValidPassword && (lowercaseLetter != nil ? true : false)
            isValidPassword = isValidPassword && (special != nil ? true : false)
            isValidPassword = isValidPassword && (upperCase != nil ? true : false)
        }

        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dismissValidateForm), userInfo: nil, repeats: false)
        
        if isValidName && isValidEmail && isValidPassword {
            register()
        }
    }
    
    @objc func dismissValidateForm() {
        let nameCell = getInputCellByName("Nome")
        let emailCell = getInputCellByName("Email")
        
        nameCell.errorMessage.isHidden = true
        emailCell.errorMessage.isHidden = true
    }
}
