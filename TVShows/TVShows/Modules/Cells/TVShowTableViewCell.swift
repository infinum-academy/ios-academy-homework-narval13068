//
//  TVShowTableViewCell.swift
//  TVShows
//
//  Created by Rino Čala on 20/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

final class TVShowTableViewCell : UITableViewCell {
    
    // MARK - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK - Lifecycle Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    // MARK: Configure Cell UI
    
    func configure(show: Show) {
        titleLabel.text = show.title
    }
}
