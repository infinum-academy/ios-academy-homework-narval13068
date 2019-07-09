//
//  LoginViewController.swift
//  TVShows
//
//  Created by Rino Čala on 05/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

final class LoginViewController : UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var sumLabel: UILabel!
    @IBOutlet private weak var increaseButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var changeStateButton: UIButton!
    
    // MARK: - Properties
    
    private var numberOfClicks: Int = 0
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onAppearConfigureUI()
    }
    
    // MARK: - Initial configuration of UI
    
    private func initialConfigureUI() {
        sumLabel.text = String(numberOfClicks)
        increaseButton.layer.cornerRadius = 10
        increaseButton.clipsToBounds = true
        changeStateButton.layer.cornerRadius = 10
        changeStateButton.clipsToBounds = true
    }
    
    // MARK: - On appear configuration of UI
    
    private func onAppearConfigureUI() {
        activityIndicator.startAnimating()
        changeStateButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.activityIndicator.stopAnimating()
            self.changeStateButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func increaseButtonTapped() {
        activityIndicator.startAnimating()
        numberOfClicks += 1
        sumLabel.text = String(numberOfClicks)
        activityIndicator.stopAnimating()
    }
    
    @IBAction private func changeStateButtonTapped() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
            changeStateButton.setTitle("Start", for: .normal)
        } else {
            activityIndicator.startAnimating()
            changeStateButton.setTitle("Stop", for: .normal)
        }
    }

}
