//
//  HomeScreenViewController.swift
//  TVShows
//
//  Created by Rino Čala on 14/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Alamofire
import PromiseKit

final class HomeScreenViewController: UIViewController {
    
    // MARK - Properties
    
    var loggedUser: LoginUser?
    private var shows: [Show]?
    
    // MARK - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: Configure UI
    
    private func setupUI() {
        setupUITableView()
        guard let token = loggedUser?.token else { return }
        _promiseKitFetchShows(token: token)
        title = "Shows"
    }
    
    private func setupUITableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: Methods for API Calls

private extension HomeScreenViewController {
    
    func _promiseKitFetchShows(token: String) {
        SVProgressHUD.show()
        let headers: [String : String] = [
            "Authorization" : token
        ]
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/shows", method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable([Show].self, keyPath: "data")
            }.done { [weak self] shows in
                self?.shows = shows
                self?.tableView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Loading TVShows failed")
        }
    }
}

// MARK: UITableViewDataSource setup methods

extension HomeScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfCells = shows?.count {
            return numberOfCells
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TVShowTableViewCell.self), for: indexPath) as! TVShowTableViewCell
        guard let arrayOfShows = shows else { return cell }
        cell.configure(show: arrayOfShows[indexPath.row])
        return cell
    }
}

// MARK - UITableViewDelegate methods for UITableView behaviour

extension HomeScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action,indexPath) in
            self.shows?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "ShowScreens", bundle: nil)
        let showDetailsViewController = storyboard.instantiateViewController(withIdentifier: "ShowDetailsViewController") as? ShowDetailsViewController
        guard let showScreen = showDetailsViewController, let arrayOfShows = shows else { return }
        showScreen.showId = arrayOfShows[indexPath.row].id
        showScreen.loggedUser = loggedUser
        navigationController?.pushViewController(showScreen, animated: true)
    }
    
}

