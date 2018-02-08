//
//  PasswordListViewController.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 01/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit
import Alamofire
import LocalAuthentication

class PasswordListViewController: BaseViewController {
    
    var swipeInteractionController: SwipeInteractionController?
    
    @IBOutlet weak var tableView: UITableView!
    var list = [SavedPasswordModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        swipeInteractionController = SwipeInteractionController(viewController: self)
        
        setLoggedUser()
        configureNavigtionItem()
        getTouchID()
        automaticLogin()
    }
    
    func getTouchID() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Favor Cadastrar a digital!"
        
        guard let savedInfoData = Keychain.get(key: UserInfoModel.loggedUser) else {
            return
        }
        let savedInfo = SavedPasswordListModel(fromString: savedInfoData)
        let touch = savedInfo.user.haveTouchID
        
        if touch == nil {
            var authError: NSError?
            if #available(iOS 8.0, *) {
                if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                    myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                        if success {
                            savedInfo.user.haveTouchID = true
                        } else {
                            savedInfo.user.haveTouchID = false
                        }
                        Keychain.set(key: savedInfo.user.user, value: savedInfo.toString())
                    }
                }
            }
        }
    }
    
    private func setLoggedUser() {
        let automaticLogin = UserDefaults.standard.string(forKey: "keepConnected")
        guard let automaticUser = automaticLogin else {
            return
        }
        if automaticUser.count > 0 {
            UserInfoModel.loggedUser = automaticUser
        }
    }
    
    func automaticLogin() {
        let automaticLogin = UserDefaults.standard.string(forKey: "keepConnected")
        guard let automaticUser = automaticLogin else {
            goToLogin()
            return
        }
        if automaticUser.count > 0 {
            guard let userString = Keychain.get(key: automaticUser) else { return }
            let savedPassword = SavedPasswordListModel(fromString: userString)
            let userInfo = savedPassword.user
            
            let service = LoginService()
            startLoading()
            service.login(user: userInfo.user, password: userInfo.password, withCompletionHandler: { afResponse in
                self.stopLoading()
                
                guard let response = afResponse.response else {
                    // erro inesperado
                    return
                }
                
                if response.statusCode != 201 {
                    //tratar para email/senha incorreta
                    return
                }
                
                if let json = afResponse.result.value {
                    if let dictionary = json as? [String: String] {
                        UserInfoModel.authorizationToken = dictionary["token"]!
                        
                        self.reloadTableView()
                    }
                }
            })
            
        }
        else {
            goToLogin()
        }
    }
    
    func reloadTableView() {
        getSavedPassword()
        tableView.reloadData()
    }
    
    func getSavedPassword() {
        if let savedInfoData = Keychain.get(key: UserInfoModel.loggedUser) {
            let savedInfo = SavedPasswordListModel(fromString: savedInfoData)
            list = savedInfo.getPasswords()
        }
    }
    
    func goToLogin() {
        UserDefaults.standard.set("", forKey: "keepConnected")
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPasswordDetailSegue" {
            if let destinationVC = segue.destination as? PasswordDetailsViewController{
                destinationVC.model = list[(tableView.indexPathForSelectedRow?.row)!]
                destinationVC.delegate = self
            }
        }
        else if segue.identifier == "addPasswordSegue" {
            if let destinationVC = segue.destination as? NewPasswordViewController{
                destinationVC.delegate = self
                destinationVC.transitioningDelegate = self
            }
        }
    }
    
    func configureNavigtionItem() {
        
        let exitButton = UIBarButtonItem(title: "Sair", style: .plain, target: self, action: #selector(logout))
        exitButton.tintColor = UIColor(red: 68/255, green: 109/255, blue: 178/255, alpha: 1.0)
        
        self.navigationItem.leftBarButtonItem = exitButton
    }
    
    @IBAction func addPasswordTouch(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "addPasswordSegue", sender: nil)
    }
    
    @objc func logout() {
        goToLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLoggedUser()
        getTouchID()
        reloadTableView()
    }
}

extension PasswordListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showPasswordDetailSegue", sender: indexPath)
    }
}

extension PasswordListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return list.count
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedPassword") as? SavedPasswordTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of SavedPasswordTableViewCell.")
        }
        cell.logo.image = self.list[indexPath.row].getLogo()
        cell.url.text = self.list[indexPath.row].url
        cell.email.text = self.list[indexPath.row].user
        
        return cell
    }
}


extension PasswordListViewController: NewPasswordDelegate {
    func didAddNewPassword() {
        reloadTableView()
    }
}

extension PasswordListViewController: PasswordDetailsDelegate {
    func passwordDeleted() {
        reloadTableView()
    }
}

extension PasswordListViewController: UIViewControllerTransitioningDelegate {
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

