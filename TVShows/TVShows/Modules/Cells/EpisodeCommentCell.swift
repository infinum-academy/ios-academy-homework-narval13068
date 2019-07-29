//
//  EpisodeCommentCell.swift
//  TVShows
//
//  Created by Rino Čala on 27/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit

final class EpisodeCommentCell: UITableViewCell {
    
    // MARK - Outlets
    
    @IBOutlet weak var iconCommentImageView: UIImageView!
    @IBOutlet private weak var commentPersonLabel: UILabel!
    @IBOutlet private weak var commentDescriptionLabel: UILabel!
    
    // MARK - Lifecycle methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconCommentImageView.image = nil
        commentPersonLabel.text = nil
        commentDescriptionLabel.text = nil
    }
    
    // MARK - Configure UI
    
    func configure(comment: Comment) {
        commentPersonLabel.text = comment.userEmail
        commentDescriptionLabel.text = comment.text
    }
    
    
    
}
