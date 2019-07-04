//
//  ViewController.swift
//  TVShows
//
//  Created by Rino Čala on 04/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

class ViewController : UIViewController {
    
    
    
    @IBOutlet weak var mySwitch: UISwitch!
    
    
    override func viewDidLoad() {
        view.backgroundColor = .red
    }
    
    @IBAction func myaction(_ sender : UISwitch) {
        if (sender.isOn == true) {
             view.backgroundColor = .yellow
        }
        else {
            view.backgroundColor = .red
        }
    }
    
}
