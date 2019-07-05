//
//  LoginViewController.swift
//  TVShows
//
//  Created by Rino Čala on 05/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController {
    
    
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var changeStateButton: UIButton!
    
    var sum : Int = 0
    
    
    
    override func viewDidLoad() {
        sumLabel.text = String(sum)
        increaseButton.layer.cornerRadius = 10
        increaseButton.clipsToBounds = true
        changeStateButton.layer.cornerRadius=10
        changeStateButton.clipsToBounds=true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        changeStateButton.isHidden=true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.activityIndicator.stopAnimating()
            self.changeStateButton.isHidden=false
        }
    }
    
    @IBAction func increaseButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        sum+=1
        sumLabel.text = String(sum)
        activityIndicator.stopAnimating()
    }
    
  
    
    @IBAction func changeStateButtonTapped(_ sender: Any) {
        if (activityIndicator.isAnimating==true) {
            activityIndicator.stopAnimating()
            changeStateButton.setTitle("Start", for: .normal)
        }
        else {
            activityIndicator.startAnimating()
            changeStateButton.setTitle("Stop", for: .normal)
        }
    }
    
    
}
