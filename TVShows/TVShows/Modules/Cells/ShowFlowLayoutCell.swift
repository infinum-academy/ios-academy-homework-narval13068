//
//  ShowFlowLayoutCell.swift
//  TVShows
//
//  Created by Rino Čala on 26/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

final class ShowFlowLayoutCell: UICollectionViewCell {
    
    // MARK - Outlets
    
    @IBOutlet private weak var showImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showImageView.image = nil
        titleLabel.text = nil
    }
    
    // MARK - Configure UI
    
    private func setupUI() {
        showImageView.layer.shadowColor = UIColor.black.cgColor
        showImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        showImageView.layer.shadowOpacity = 1
        showImageView.layer.shadowRadius = 2.0
        showImageView.clipsToBounds = false
    }
    
    func configure(show: Show) {
        let url = URL(string: "https://api.infinum.academy"+show.imageUrl)
        titleLabel.text = show.title
        showImageView.kf.setImage(with: url)
    }
}
