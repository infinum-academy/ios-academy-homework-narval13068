//
//  EpisodeCommentsViewController.swift
//  TVShows
//
//  Created by Rino Čala on 27/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import PromiseKit
import SVProgressHUD

final class EpisodeCommentsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK - Properties
    
    var loggedUser: LoginUser?
    var episode: Episode?
    private var comments: [Comment]?
    private var refreshControl = UIRefreshControl()
    
    // MARK - Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var commentTextField: UITextField!
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet private weak var commentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var roundedViewAroundTextField: UIView!
    @IBOutlet private weak var noCommentsIconImageView: UIImageView!
    @IBOutlet private weak var noCommentsTextLabel: UILabel!
    
    // MARK - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK - Configure UI
    
    private func setupUI() {
        setupUITableView()
        textFieldSetup()
        guard let token = loggedUser?.token, let id = episode?.id else { return }
        _promiseKitFetchComments(token: token, id: id)
        setupKeyboardNotificationCenter()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    private func textFieldSetup() {
        commentTextField.delegate = self
        roundedViewAroundTextField.layer.cornerRadius = 15
        roundedViewAroundTextField.clipsToBounds = true
        roundedViewAroundTextField.layer.borderWidth = 1
        roundedViewAroundTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupUITableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        refreshControl.addTarget(self,action: #selector(updateUITableView),for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func setupKeyboardNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK - Refresh Control function
    
    @objc private func updateUITableView () {
        guard let token = loggedUser?.token, let id = episode?.id else { return }
        _promiseKitFetchComments(token: token, id: id)
        refreshControl.endRefreshing()
    }
    
    // MARK - Navigation
    
    @IBAction private func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK - Dismissing keyboard
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func viewTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK - Moving comment field above keyboard
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keywindow = UIApplication.shared.keyWindow
        guard let window = keywindow else { return }
        let bottomPadding = window.safeAreaInsets.bottom
        commentViewBottomConstraint.constant = -keyboardSize.height+bottomPadding
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        commentViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    // MARK - New comment posting

    @IBAction private func postButtonTapped(_ sender: Any) {
        guard let token = loggedUser?.token, let id = episode?.id, let text = commentTextField.text else { return }
        _promiseKitPostComment(token: token, id: id, text: text)
        commentTextField.text = ""
        view.endEditing(true)
    }
}

// MARK - Api calls

private extension EpisodeCommentsViewController {
    
    func _promiseKitFetchComments(token: String, id: String) {
        let headers: [String : String] = [
            "Authorization" : token
        ]
        SVProgressHUD.show()
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/episodes/\(id)/comments", method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable([Comment].self, keyPath: "data")
            }.done { [weak self] comments in
                self?.comments = comments
                self?.tableView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Loading Comments failed")
        }
    }
    
    func _promiseKitPostComment(token: String, id: String, text: String) {
        let headers: [String : String] = [
            "Authorization" : token
        ]
        let parameters: [String : String] = [
            "text" : text,
            "episodeId" : id
        ]
        firstly {
            Alamofire
                .request("https://api.infinum.academy/api/comments", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable(NewComment.self, keyPath: "data")
            }.done { [weak self] episode in
                self?._promiseKitFetchComments(token: token, id: id)
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showErrorMessage(message: "Adding Comment failed")
        }
    }
}

// MARK - UITableView DataSource functions

extension EpisodeCommentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfCells =  comments?.count, numberOfCells != 0 {
            noCommentsTextLabel.isHidden = true
            noCommentsIconImageView.isHidden = true
            return numberOfCells
        }
        noCommentsTextLabel.isHidden = false
        noCommentsIconImageView.isHidden = false
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EpisodeCommentCell.self), for: indexPath) as! EpisodeCommentCell
        guard let arrayOfComments = comments else { return cell }
        cell.configure(comment: arrayOfComments[indexPath.row])
        if indexPath.row % 3 == 0 { cell.iconCommentImageView.image = UIImage(named: "img-placeholder-user1")}
        else if indexPath.row % 3 == 1 {cell.iconCommentImageView.image = UIImage(named: "img-placeholder-user2")}
        else {cell.iconCommentImageView.image = UIImage(named: "img-placeholder-user3")}
        return cell
    }
}

// MARK - UITableView Delegate functions

extension EpisodeCommentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
