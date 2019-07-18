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


final class LoginViewController : UIViewController,UITextFieldDelegate {
    
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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
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
             print(password)
            _promiseKitRegisterUserWith(email: username, password: password)
            self.view.endEditing(true)
       }
    }
    
    // MARK - Dismissing keyboard
    
    @objc private func viewTapped (sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK - Navigation
    
    private func showHomeScreen() {
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let homeScreenViewController = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as? HomeScreenViewController
        if let homeScreen = homeScreenViewController {
            self.navigationController?.pushViewController(homeScreen, animated: true)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            print("Push of HomeScreen Failed")
        }
    }
    
}

// MARK - Api Calls

private extension LoginViewController {
    
    func _promiseKitRegisterUserWith(email: String,password: String) {
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
            }.catch { error in
                 print("API failure: \(error)")
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
                .responseDecodable(LoginUser.self,keyPath: "data")
            }.done { [weak self] loggedUser in
                self?.loggedUser=loggedUser
                self?.showHomeScreen()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { error in
                 print("API failure: \(error)")
            }
    }
}
