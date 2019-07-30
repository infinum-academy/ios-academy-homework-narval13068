//
//  EpisodeScreenViewController.swift
//  TVShows
//
//  Created by Rino Čala on 27/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import Alamofire
import SVProgressHUD
import Kingfisher

final class EpisodeScreenViewController: UIViewController {
    
    // MARK - Outlets
    
    @IBOutlet private weak var episodeImageView: UIImageView!
    @IBOutlet private weak var episodeTitleLabel: UILabel!
    @IBOutlet private weak var seasonNumberLabel: UILabel!
    @IBOutlet private weak var episodeNumberLabel: UILabel!
    @IBOutlet private weak var episodeDescriptionLabel: UILabel!
    @IBOutlet private weak var commentsView: UIView!
    
    // MARK - Properties
    
    var loggedUser: LoginUser?
    var episode: Episode?
    
    // MARK - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK - Configure UI
    
    private func setupUI() {
        guard let id = episode?.id, let token = loggedUser?.token else { return }
        _promiseKitFetchEpisodeDetails(id: id, token: token)
        commentsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showComments)))
    }
    
    // MARK - Navigation
    
    @objc private func showComments(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "EpisodeComments", bundle: nil)
        let episodeCommentsViewController = storyboard.instantiateViewController(withIdentifier: "EpisodeCommentsViewController") as? EpisodeCommentsViewController
        guard let commentsScreen = episodeCommentsViewController else { return }
        commentsScreen.loggedUser = loggedUser
        commentsScreen.episode = episode
        present(commentsScreen, animated: true, completion: nil)
    }

    @IBAction private func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK - Setting up episode details on screen
    
    private func setupEpisodeDetails(episodeDetails: EpisodeDetails) {
        let url = URL(string: "https://api.infinum.academy"+episodeDetails.imageUrl)
        episodeImageView.kf.setImage(with: url)
        episodeTitleLabel.text = episodeDetails.title
        seasonNumberLabel.text = "S" + episodeDetails.season
        episodeNumberLabel.text = "Ep" + episodeDetails.episodeNumber
        episodeDescriptionLabel.text = episodeDetails.description
    }
    
}

// MARK - Api Calls

private extension EpisodeScreenViewController {
    
    func _promiseKitFetchEpisodeDetails(id: String, token: String) {
        let headers: [String : String] = [
            "Authorization" : token
        ]
        SVProgressHUD.show()
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/episodes/"+id, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable(EpisodeDetails.self, keyPath: "data")
            }.done { [weak self] episodeDetails in
                self?.setupEpisodeDetails(episodeDetails: episodeDetails)
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Loading Episode Details failed")
        }
    }
}
