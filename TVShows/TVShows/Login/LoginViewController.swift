//
//  LoginViewController.swift
//  TVShows
//
//  Created by Rino Čala on 11/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

final class LoginViewController : UIViewController,UITextFieldDelegate {
    
    // MARK - Outlets
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    
    // MARK - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigureUI()
    }
    
    // MARK - UI Configure
    
    private func initialConfigureUI() {
        loginButton.layer.cornerRadius = 5
        scrollView.showsVerticalScrollIndicator = false
        usernameField.delegate = self
        passwordField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    // MARK - Actions
    
    @IBAction private func rememberMeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    // MARK - Dismissing keyboard
    
    @objc private func viewTapped (sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
