//
//  PasswordDetailsViewController.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 03/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

protocol PasswordDetailsDelegate {
    func passwordDeleted()
}

class PasswordDetailsViewController: BaseViewController {

    var swipeInteractionController: SwipeInteractionController?
    var lockButton = UIBarButtonItem()
    
    @IBOutlet weak var scrollView: UIScrollView!
    var delegate: PasswordDetailsDelegate?
    var editable = false
    var showingPassword = false
    var obfuscatedPassword: String {
        get {
            var obfuscated = ""
            for _ in model.password {
                obfuscated += "•"
            }
            return obfuscated
        }
    }
    
    var model = SavedPasswordModel()
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var user: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var deletePasswordButton: UIButton!
    
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var copyPasswordButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transitioningDelegate = self
        swipeInteractionController = SwipeInteractionController(viewController: self)
        setKeyboardAvoidance(scrollView: scrollView)
        configureNavigationItem()
        initForm()
    }
    
    func configureNavigationItem() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
        let navItem = UINavigationItem(title: "Detalhes")
        let lockButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(LockButtonTouch))
        lockButton.setBackgroundImage(#imageLiteral(resourceName: "lockLocked"), for: .normal, barMetrics: .default)
        lockButton.setBackgroundImage(#imageLiteral(resourceName: "lockLocked"), for: .selected, barMetrics: .default)
        
        let backItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(backButtonBar))
        
        navItem.rightBarButtonItem = lockButton
        navItem.leftBarButtonItem = backItem
        navBar.setItems([navItem], animated: false)
        
        self.view.addSubview(navBar)
        
        self.lockButton = lockButton
    }
    
    func initForm() {
        url.text = model.url
        user.text = model.user
        password.text = obfuscatedPassword
        logo.image = model.getLogo()
    }
    
    @objc func backButtonBar() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func LockButtonTouch() {
        saveChangesButton.isHidden = editable
        deletePasswordButton.isHidden = editable
        
        editable = !editable
        
        if editable {
            lockButton.setBackgroundImage(#imageLiteral(resourceName: "lockOpen"), for: .normal, barMetrics: .default)
            lockButton.setBackgroundImage(#imageLiteral(resourceName: "lockOpen"), for: .selected, barMetrics: .default)
            
            showPasswordButton.isHidden = true
            copyPasswordButton.isHidden = true
            password.text = model.password
        } else {
            lockButton.setBackgroundImage(#imageLiteral(resourceName: "lockLocked"), for: .normal, barMetrics: .default)
            lockButton.setBackgroundImage(#imageLiteral(resourceName: "lockLocked"), for: .selected, barMetrics: .default)
            
            showPasswordButton.isHidden = false
            password.text = obfuscatedPassword
        }
        self.url.isEnabled = editable
        self.user.isEnabled = editable
        self.password.isEnabled = editable
    }

    
    @IBAction func showHidePassword(_ sender: UIButton) {
        copyPasswordButton.isHidden = showingPassword
        showingPassword = !showingPassword
        if showingPassword {
            showPasswordButton.setBackgroundImage(#imageLiteral(resourceName: "eyeOpen"), for: .normal)
            showPasswordButton.setBackgroundImage(#imageLiteral(resourceName: "eyeOpen"), for: .selected)
            
            password.text = model.password
        } else {
            showPasswordButton.setBackgroundImage(#imageLiteral(resourceName: "eyeClosed"), for: .normal)
            showPasswordButton.setBackgroundImage(#imageLiteral(resourceName: "eyeClosed"), for: .selected)
            
            password.text = obfuscatedPassword
        }
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        guard let savedInfoString = Keychain.get(key: UserInfoModel.loggedUser) else { return }
        
        let oldInfo = SavedPasswordListModel(fromString: savedInfoString)

        model.url = url.text!
        model.user = user.text!
        model.password = password.text!
        
        oldInfo.updateFromPasswords(newValue: model)
        
        Keychain.set(key: UserInfoModel.loggedUser, value: oldInfo.toString())
    }
    
    @IBAction func deletePassword(_ sender: UIButton) {
        guard let savedInfoString = Keychain.get(key: UserInfoModel.loggedUser) else { return }
        
        let oldInfo = SavedPasswordListModel(fromString: savedInfoString)
        
        oldInfo.deleteFromPasswords(value: model)
        
        Keychain.set(key: UserInfoModel.loggedUser, value: oldInfo.toString())
        
        delegate?.passwordDeleted()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func copyPassword(_ sender: UIButton) {
        UIPasteboard.general.string = model.password
    }
}

extension PasswordDetailsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return CubeAnimationController(showing: true, interactionController: self.swipeInteractionController)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return CubeAnimationController(showing: false, interactionController: self.swipeInteractionController)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? CubeAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            guard let animator = animator as? CubeAnimationController,
                let interactionController = animator.interactionController,
                interactionController.interactionInProgress
                else {
                    return nil
            }
            return interactionController
    }
}
