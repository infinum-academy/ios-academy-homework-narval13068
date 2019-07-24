//
//  LoginViewController.swift
//  TVShows
//
//  Created by Rino Čala on 11/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD
import CodableAlamofire
import PromiseKit


final class LoginViewController : UIViewController, UITextFieldDelegate {
    
    // MARK - Outlets
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    
    // MARK - Properties

    private var registeredUser: User?
    private var loggedUser: LoginUser?
    
    // MARK - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK - UI Configure
    
    private func initialConfigureUI() {
        loginButton.layer.cornerRadius = 5
        scrollView.showsVerticalScrollIndicator = false
        usernameField.delegate = self
        passwordField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFinishedShowing), name: UIResponder.keyboardDidHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        SVProgressHUD.setDefaultMaskType(.black)
    }
    
    // MARK - Actions
    
    @IBAction private func rememberMeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction private func logInPushed(_ sender: UIButton) {
        if let username = usernameField.text, !username.isEmpty, let password = passwordField.text, !password.isEmpty {
            _promiseKitLoginUserWith(email: username, password: password)
            self.view.endEditing(true)
        }
    }
    
    @IBAction private func createAccountPushed(_ sender: UIButton) {
       if let username = usernameField.text, !username.isEmpty, let password = passwordField.text, !password.isEmpty {
            _promiseKitRegisterUserWith(email: username, password: password)
            self.view.endEditing(true)
       }
    }
    
    // MARK - Dismissing keyboard
    
    @objc private func viewTapped (sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK - Moving Scrollview for showing textfields when keyboard overlaps them
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        }
    }
        
    @objc private func keyboardFinishedShowing(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    // MARK - Navigation
    
    private func showHomeScreen() {
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let homeScreenViewController = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as? HomeScreenViewController
        if let homeScreen = homeScreenViewController {
            homeScreen.loggedUser = self.loggedUser
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setViewControllers([homeScreen], animated: true)
        }
    }
    
    // MARK: Show Error message
    
    private func showErrorMessage(message: String) {
        let title = "Error"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK - Api Calls

private extension LoginViewController {
    
    func _promiseKitRegisterUserWith(email: String, password: String) {
        SVProgressHUD.show()
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/users", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
               .responseDecodable(User.self, keyPath: "data")
            }.then { [weak self] (user: User) -> Promise<LoginUser> in
                self?.registeredUser = user
                return Alamofire
                    .request("https://api.infinum.academy/api/users/sessions", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .validate()
                    .responseDecodable(LoginUser.self, keyPath: "data")
            }
            .done { [weak self] loggedUser in
                self?.loggedUser = loggedUser
                self?.showHomeScreen()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                 self?.showErrorMessage(message: "Registering new user failed")
            }
    }
    
    func _promiseKitLoginUserWith(email: String, password: String) {
        SVProgressHUD.show()
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/users/sessions", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(LoginUser.self, keyPath: "data")
            }.done { [weak self] loggedUser in
                self?.loggedUser=loggedUser
                self?.showHomeScreen()
                print(loggedUser.token)
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Logging in failed")
            }
    }
}
