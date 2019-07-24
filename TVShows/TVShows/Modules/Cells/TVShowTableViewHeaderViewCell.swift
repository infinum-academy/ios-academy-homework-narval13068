//
//  TVShowTableViewHeaderViewCell.swift
//  TVShows
//
//  Created by Rino Čala on 23/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

class TVShowTableViewHeaderViewCell : UITableViewCell {
    
    // MARK - Properties
    
    @IBOutlet weak var showTitle: UILabel!
    @IBOutlet weak var showDescription: UILabel!
    @IBOutlet weak var numberOfEpisodes: UILabel!
    
    // MARK - Lifecycle methods
    
     override func prepareForReuse() {
        super.prepareForReuse()
        showTitle.text = nil
        showDescription.text = nil
        numberOfEpisodes.text = nil
     }
    
    // MARK - Configure Cell UI
    
    func configure(details: ShowDetails, count: Int) {
        showTitle.text = details.title
        showDescription.text = details.description
        numberOfEpisodes.text = String(count)
    }
    
}
