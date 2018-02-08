//
//  NewPasswordViewController.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

protocol NewPasswordDelegate {
    func didAddNewPassword()
}

class NewPasswordViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var urlCell:InputTableViewCell {
        get {
            return getInputCellByName("Site")
        }
    }
    var userCell:InputTableViewCell {
        get {
            return getInputCellByName("Usuário")
        }
    }
    var passwordCell:InputTableViewCell {
        get {
            return getInputCellByName("Senha")
        }
    }
    
    var delegate: NewPasswordDelegate?
    
    var user: String = ""
    let formInputs = ["Site", "Usuário", "Senha"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.transitioningDelegate = self
        setKeyboardAvoidance(scrollView: scrollView)
    }
    
    @IBAction func doClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getInputCellByName(_ name:String) -> InputTableViewCell {
        guard let cell = tableView.cellForRow(at: IndexPath(item: self.formInputs.index(of: name)!, section: 0)) as? InputTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of InputTableViewCell.")
        }
        
        return cell
    }
}

extension NewPasswordViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formInputs.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case formInputs.count:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as? ButtonTableViewCell
                else {
                    fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")
            }
            cell.delegate = self
            
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell") as? InputTableViewCell
                else {
                    fatalError("The dequeued cell is not an instance of InputTableViewCell.")
            }
            if indexPath.row == formInputs.index(of: "Senha") {
                cell.input.isSecureTextEntry = true
            }
            
            cell.input.placeholder = self.formInputs[indexPath.row]
            
            return cell
        }
    }
}

extension NewPasswordViewController: ButtonTableViewCellDelegate {
    func buttonTouchUpInside(cell: ButtonTableViewCell) {
        if validateForm() {
            guard let savedInfoString = Keychain.get(key: UserInfoModel.loggedUser) else { return }
            
            let oldInfo = SavedPasswordListModel(fromString: savedInfoString)
            
            let newPassword = SavedPasswordModel()
            
            let service = PasswordSaveServices()
            
            newPassword.url = urlCell.input.text!
            newPassword.user = userCell.input.text!
            newPassword.password = passwordCell.input.text!
            
            startLoading()
            service.downloadLogo(forUrl: urlCell.input.text!, withCompletionHandler: { image in
                self.stopLoading()
                
                var siteImage: UIImage
                let fisrt = UIImagePNGRepresentation(image);
                let second = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultWrong"));
                if fisrt == second {
                    siteImage = #imageLiteral(resourceName: "defaultSiteImagebig")
                } else {
                    siteImage = image
                }
                
                newPassword.setLogo(image: siteImage)
                
                oldInfo.addToPasswords(value: newPassword)
                
                Keychain.set(key: UserInfoModel.loggedUser, value: oldInfo.toString())
                
                self.dismiss(animated: true, completion: nil)
                self.delegate?.didAddNewPassword()
            })
        }
    }
    
    func validateForm() -> Bool{
        var isValidURL = false
        var isValidUser = false
        var isValidPassword = false
        
        urlCell.errorMessage.text = "Favor preencher a URL"
        userCell.errorMessage.text = "Favor preencher o usuário"
        passwordCell.errorMessage.text = "Favor preencher a senha"
        
        if let url = urlCell.input.text {
            isValidURL = url.count > 0
            urlCell.errorMessage.isHidden = isValidURL
        }
        if let user = userCell.input.text {
            isValidUser = user.count > 0
            userCell.errorMessage.isHidden = isValidUser
        }
        if let password = passwordCell.input.text {
            isValidPassword = password.count > 0
            passwordCell.errorMessage.isHidden = isValidPassword
        }

        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissValidateForm), userInfo: nil, repeats: false)
        
        return isValidURL && isValidUser && isValidPassword
    }
    
    @objc func dismissValidateForm() {
        
        urlCell.errorMessage.isHidden = true
        userCell.errorMessage.isHidden = true
        passwordCell.errorMessage.isHidden = true
    }
}

extension NewPasswordViewController: UIViewControllerTransitioningDelegate {
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
