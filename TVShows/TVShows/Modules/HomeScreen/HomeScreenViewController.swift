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
import Keychain

final class HomeScreenViewController: UIViewController {
    
    // MARK - Properties
    
    var loggedUser: LoginUser?
    private var shows: [Show]?
    private var flowLayout: Bool = false
    private var gridButton: UIBarButtonItem?
    private var flowButton: UIBarButtonItem?
    
    // MARK - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Configure UI
    
    private func setupUI() {
        setupUICollectionView()
        guard let token = loggedUser?.token else { return }
        _promiseKitFetchShows(token: token)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Shows"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-logout"), style: .plain, target: self, action: #selector(logoutUser))
        gridButton = UIBarButtonItem(image: UIImage(named: "ic-gridview"), style: .plain, target: self, action: #selector(changeCollectionViewLayout))
        flowButton = UIBarButtonItem(image: UIImage(named: "ic-listview"), style: .plain, target: self, action: #selector(changeCollectionViewLayout))
        navigationItem.rightBarButtonItem = flowButton
        navigationController?.navigationBar.tintColor = UIColor.darkGray
    }
    
    private func setupUICollectionView() {
        collectionView.register(UINib(nibName: "ShowGridLayoutCell", bundle: nil), forCellWithReuseIdentifier: "ShowGridLayoutCell")
        collectionView.register(UINib(nibName: "ShowFlowLayoutCell", bundle: nil), forCellWithReuseIdentifier: "ShowFlowLayoutCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
    }
    
    // MARK - Logout user
    
    @objc private func logoutUser() {
        _ = Keychain.delete("loginEmail")
        _ = Keychain.delete("loginPassword")
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        guard let loginScreen = loginViewController else { return }
        self.navigationController?.setViewControllers([loginScreen], animated: true)
    }
    
    // MARK - Change UICollectionView layout between flow and grid layout
    
    @objc private func changeCollectionViewLayout() {
        if flowLayout {
            navigationItem.rightBarButtonItem = flowButton
        } else {
            navigationItem.rightBarButtonItem = gridButton
        }
        flowLayout = !flowLayout
        collectionView.reloadData()
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
                self?.collectionView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Loading TVShows failed")
        }
    }
}

// MARK: UICollectionViewDataSource setup methods

extension HomeScreenViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfCells = shows?.count {
            return numberOfCells
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if flowLayout {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ShowFlowLayoutCell.self), for: indexPath) as! ShowFlowLayoutCell
            guard let arrayOfShows = shows else { return cell }
            cell.configure(show: arrayOfShows[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ShowGridLayoutCell.self), for: indexPath) as! ShowGridLayoutCell
            guard let arrayOfShows = shows else { return cell }
            cell.configure(show: arrayOfShows[indexPath.row])
            return cell
        }
    }
    
}

// MARK - UICollectionViewDelegate methods

extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "ShowScreens", bundle: nil)
        let showDetailsViewController = storyboard.instantiateViewController(withIdentifier: "ShowDetailsViewController") as? ShowDetailsViewController
        guard let showScreen = showDetailsViewController, let arrayOfShows = shows else { return }
        showScreen.showId = arrayOfShows[indexPath.row].id
        showScreen.loggedUser = loggedUser
        navigationController?.pushViewController(showScreen, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        if flowLayout {
            return CGSize(width: width, height: 110)
        } else {
            let scale = (width / 2.1)
            return CGSize(width: scale, height: scale)
        }
    }
}

// MARK: Show Error message

extension UIViewController {
   
    func showErrorMessage(message: String) {
        let title = "Error"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

