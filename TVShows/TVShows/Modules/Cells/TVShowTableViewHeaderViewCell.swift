//
//  TVShowTableViewHeaderViewCell.swift
//  TVShows
//
//  Created by Rino Čala on 23/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

final class TVShowTableViewHeaderViewCell : UITableViewCell {
    
    // MARK - Properties
    
    @IBOutlet private weak var showTitle: UILabel!
    @IBOutlet private weak var showDescription: UILabel!
    @IBOutlet private weak var numberOfEpisodes: UILabel!
    @IBOutlet private weak var showImageView: UIImageView!
    
    // MARK - Lifecycle methods
    
     override func prepareForReuse() {
        super.prepareForReuse()
        showTitle.text = nil
        showDescription.text = nil
        numberOfEpisodes.text = nil
        showImageView.image = nil
     }
    
    // MARK - Configure Cell UI
    
    func configure(details: ShowDetails, count: Int) {
        showTitle.text = details.title
        showDescription.text = details.description
        numberOfEpisodes.text = String(count)
        let url = URL(string: "https://api.infinum.academy"+details.imageUrl)
        showImageView.kf.setImage(with: url)
    }
    
}
