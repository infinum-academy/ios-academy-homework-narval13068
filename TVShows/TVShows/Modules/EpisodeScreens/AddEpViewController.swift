//
//  AddEpViewController.swift
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

protocol ShowReloadEpisodesDelegate: class {
    func showReloadEpisodes()
}

final class AddEpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK - Properties
    
    var showId: String?
    var loggedUser: LoginUser?
    weak var delegate: ShowReloadEpisodesDelegate?
    
    // MARK - Outlets
    
    @IBOutlet private weak var episodeTitleField: UITextField!
    @IBOutlet private weak var seasonNField: UITextField!
    @IBOutlet private weak var episodeNField: UITextField!
    @IBOutlet private weak var episodeDescrField: UITextField!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK - App Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK - Configure UI
    
    private func setupUI() {
        textFieldSetup()
        navigationBarSetup()
        notificationCenterSetup()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    private func notificationCenterSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFinishedShowing), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    private func navigationBarSetup() {
        title = "Add episode"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didSelectCancelAddEp))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "Pink")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didSelectAddEp))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "Pink")
    }
    
    private func textFieldSetup() {
        episodeTitleField.delegate = self
        seasonNField.delegate = self
        episodeNField.delegate = self
        episodeDescrField.delegate = self
    }
    
    // MARK - Actions on tapped Navigation Item
    
    @objc private func didSelectCancelAddEp() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didSelectAddEp() {
        guard let id = showId, let token = loggedUser?.token, let title = episodeTitleField.text, !title.isEmpty, let description = episodeDescrField.text, !description.isEmpty, let episodeNumber = episodeNField.text, !episodeNumber.isEmpty, let season = seasonNField.text, !season.isEmpty else { return }
        _promiseKitPostNewEp(id: id, title: title, description: description, episodeNumber: episodeNumber, season: season, token: token)
    }
    
    // MARK - Moving Scrollview for showing textfields when keyboard overlaps them
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
    }
    
    @objc private func keyboardFinishedShowing(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    // MARK - Dismissing keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func viewTapped (sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

// MARK - API Calls

private extension AddEpViewController {
    
    func _promiseKitPostNewEp(id: String, title: String, description: String, episodeNumber: String, season: String, token: String) {
        SVProgressHUD.show()
        let parameters: [String : String] = [
            "showId" : id,
            "mediaId" : "someMedia.jpg",
            "title" : title,
            "description" : description,
            "episodeNumber" : episodeNumber,
            "season" : season
        ]
        let headers: [String : String] = [
            "Authorization" : token
        ]
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/episodes", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable(NewEpisode.self, keyPath: "data")
            }.done { [weak self] episode in
                self?.delegate?.showReloadEpisodes()
                self?.dismiss(animated: true, completion: nil)
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                print(error)
                self?.showErrorMessage(message: "Adding Episode failed")
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
