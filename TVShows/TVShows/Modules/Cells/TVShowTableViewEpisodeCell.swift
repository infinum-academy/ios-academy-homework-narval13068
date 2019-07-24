//
//  TVShowTableViewEpisodeCell.swift
//  TVShows
//
//  Created by Rino Čala on 21/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

final class TVShowTableViewEpisodeCell : UITableViewCell {
    
    // MARK - Outlets
    
    @IBOutlet private weak var seasonLabel: UILabel!
    @IBOutlet private weak var episodeLabel: UILabel!
    @IBOutlet private weak var episodeTitleLabel: UILabel!
    
    // MARK - Lifecycle Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        seasonLabel.text = nil
        episodeLabel.text = nil
        episodeTitleLabel.text = nil
    }
    
    // MARK: Configure Cell UI
    
    func configure(episode: Episode) {
        seasonLabel.text = "S"+episode.season
        episodeLabel.text = "Ep"+episode.episodeNumber
        episodeTitleLabel.text = "Ep"+episode.title
    }
}
