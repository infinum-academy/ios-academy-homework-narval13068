//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Rino Čala on 21/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import Alamofire
import SVProgressHUD

final class ShowDetailsViewController: UIViewController {
    
    // MARK - Properties
    
    var showId: String?
    var loggedUser: LoginUser?
    private var showEpisodes: [Episode]?
    private var showDetails: ShowDetails?
    
    // MARK - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK - Configure UI

    private func setupUI() {
        setupTableView()
        guard let id = showId, let token = loggedUser?.token else { return }
        _promiseKitFetchShowDetails(id: id, token: token)
        _promiseKitFetchShowEpisodes(id: id, token: token)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK - Navigation
    
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func addEpisodeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "EpisodeScreens", bundle: nil)
        let addEpViewController = storyboard.instantiateViewController(withIdentifier: "AddEpViewController") as? AddEpViewController
        guard let appEpScreen = addEpViewController else { return }
        appEpScreen.showId = showId
        appEpScreen.loggedUser = loggedUser
        appEpScreen.delegate = self
        let navigationController = UINavigationController(rootViewController: appEpScreen)
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: Methods for API Calls

private extension ShowDetailsViewController {
    
    func _promiseKitFetchShowDetails(id: String, token: String) {
        let headers: [String : String] = [
            "Authorization" : token
        ]
        SVProgressHUD.show()
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/shows/"+id, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable(ShowDetails.self, keyPath: "data")
            }.done { [weak self] showDetails in
                self?.showDetails = showDetails
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Loading Show Details failed")
        }
    }
    
    func _promiseKitFetchShowEpisodes(id: String, token: String) {
        let headers: [String : String] = [
            "Authorization" : token
        ]
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/shows/"+id+"/episodes", method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable([Episode].self, keyPath: "data")
            }.done { [weak self] episodes in
                self?.showEpisodes = episodes
                self?.tableView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Loading Episodes failed")
        }
    }
}

// MARK: UITableViewDataSource setup methods

extension ShowDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfCells = showEpisodes?.count {
            return numberOfCells+1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row>0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TVShowTableViewEpisodeCell.self), for: indexPath) as! TVShowTableViewEpisodeCell
            guard let arrayOfEpisodes = showEpisodes else { return cell }
            cell.configure(episode: arrayOfEpisodes[indexPath.row-1])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TVShowTableViewHeaderViewCell.self), for: indexPath) as! TVShowTableViewHeaderViewCell
            guard let details = showDetails, let arrayOfEpisodes = showEpisodes else { return cell }
            cell.configure(details: details, count: arrayOfEpisodes.count)
            return cell
        }
    }
}

// MARK - UITableViewDelegate methods for UITableView behaviour

extension ShowDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK - Delegate methods for reloading UITableView after episode was added

extension ShowDetailsViewController: ShowReloadEpisodesDelegate {
    
    func showReloadEpisodes() {
        guard let id = showId, let token = loggedUser?.token else { return }
        _promiseKitFetchShowEpisodes(id: id, token: token)
    }
}
