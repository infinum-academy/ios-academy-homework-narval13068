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
    private let imagePicker = UIImagePickerController()
    private var media: Media?
    
    // MARK - Outlets
    
    @IBOutlet private weak var cameraImageView: UIImageView!
    @IBOutlet private weak var uploadPhotoButton: UIButton!
    @IBOutlet private weak var episodeImageView: UIImageView!
    @IBOutlet private weak var episodeTitleField: UITextField!
    @IBOutlet private weak var seasonNField: UITextField!
    @IBOutlet private weak var episodeNField: UITextField!
    @IBOutlet private weak var episodeDescrField: UITextField!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var episodeTitleStackView: UIStackView!
    @IBOutlet private weak var seasonNumberStackView: UIStackView!
    @IBOutlet private weak var episodeNumberStackView: UIStackView!
    @IBOutlet private weak var episodeDescriptionStackView: UIStackView!
    
    
    // MARK - App Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK - Configure UI
    
    private func setupUI() {
        title = "Add episode"
        episodeTitleField.delegate = self
        seasonNField.delegate = self
        episodeNField.delegate = self
        episodeDescrField.delegate = self
        imagePicker.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didSelectCancelAddEp))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "Pink")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didSelectAddEp))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "Pink")
        scrollView.showsVerticalScrollIndicator = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFinishedShowing), name: UIResponder.keyboardDidHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        episodeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhotoTapHandler)))
        cameraImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhotoTapHandler)))
        uploadPhotoButton.addTarget(self, action: #selector(addPhotoTapHandler), for: .touchUpInside)
        
    }
    
    // MARK - Actions on tapped Navigation Item
    
    @objc private func didSelectCancelAddEp() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didSelectAddEp() {
        if let id = showId, let token = loggedUser?.token, let title = episodeTitleField.text, !title.isEmpty, let description = episodeDescrField.text, !description.isEmpty,
            let episodeNumber = episodeNField.text, !episodeNumber.isEmpty, let season = seasonNField.text, !season.isEmpty, let media = media {
            _promiseKitPostNewEp(id: id, title: title, description: description, episodeNumber: episodeNumber, season: season, token: token, mediaId: media.id)
        } else if let title = episodeTitleField.text, title.isEmpty {
            episodeTitleFieldShakeAnimation()
        } else if let season = seasonNField.text, season.isEmpty {
            seasonNumberFieldShakeAnimation()
        } else if let episodeNumber = episodeNField.text, episodeNumber.isEmpty {
            episodeNumberFieldShakeAnimation()
        } else if let episodeDescription = episodeDescrField.text, episodeDescription.isEmpty {
            episodeDescriptionFieldShakeAnimation()
        } else {
            uploadPhotoButtonShakeAnimation()
        }
    }
    
    // MARK - Moving Scrollview for showing textfields when keyboard overlaps them
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        }
    }
    
    @objc private func keyboardFinishedShowing(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    // MARK - Dismissing keyboard
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func viewTapped (sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: Show Error message
    
    private func showErrorMessage(message: String) {
        let title = "Error"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK - Process of UploadRequest
    
    private func processUploadRequest(_ uploadRequest: UploadRequest) {
        uploadRequest.responseDecodableObject(keyPath: "data") { [weak self] (response: DataResponse<Media>) in
            switch response.result {
            case .success(let media):
                self?.media = media
            case .failure(_):
                self?.showErrorMessage(message: "Cannot Upload Image")
            }
        }
    }
    
}

// MARK - API Calls

private extension AddEpViewController {
    
    func _promiseKitPostNewEp(id: String, title: String, description: String, episodeNumber: String, season: String, token: String, mediaId: String) {
        SVProgressHUD.show()
        let parameters: [String : String] = [
            "showId" : id,
            "mediaId" : mediaId,
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
                self?.showErrorMessage(message: "Adding Episode failed")
        }
    }
    
    func _uploadImageOnApi(image: UIImage, token: String) {
        SVProgressHUD.show()
        let headers = ["Authorization": token]
        let imageByteData = image.pngData()!
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageByteData,
                                         withName: "file",
                                         fileName: "image.png",
                                         mimeType: "image/png")
            }, to: "https://api.infinum.academy/api/media",
               method: .post,
               headers: headers)
            { [weak self] result in
                SVProgressHUD.dismiss()
                switch result {
                case .success(let uploadRequest, _, _):
                    self?.processUploadRequest(uploadRequest)
                case .failure(_):
                    self?.showErrorMessage(message: "Cannot Upload Image")
                }
        }
    }
}

// MARK - UIImagePickerController showing and chosen photo upload

extension AddEpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func addPhotoTapHandler(sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if let token = loggedUser?.token {
                 _uploadImageOnApi(image: image, token: token)
                episodeImageView.image = image
                episodeImageView.isHidden = false
                cameraImageView.isHidden = true
                uploadPhotoButton.isHidden = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK - Animations

private extension AddEpViewController {
    
    func episodeTitleFieldShakeAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.episodeTitleStackView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.episodeTitleStackView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2 , delay: 0.4, animations: {
            self.episodeTitleStackView.transform = .identity
        })
    }
    
    func seasonNumberFieldShakeAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.seasonNumberStackView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.seasonNumberStackView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2 , delay: 0.4, animations: {
            self.seasonNumberStackView.transform = .identity
        })
    }
    
    func episodeNumberFieldShakeAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.episodeNumberStackView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.episodeNumberStackView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2 , delay: 0.4, animations: {
            self.episodeNumberStackView.transform = .identity
        })
    }
    
    func episodeDescriptionFieldShakeAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.episodeDescriptionStackView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.episodeDescriptionStackView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2 , delay: 0.4, animations: {
            self.episodeDescriptionStackView.transform = .identity
        })
    }
    
    func uploadPhotoButtonShakeAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.uploadPhotoButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.uploadPhotoButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 100)
        })
        UIView.animate(withDuration: 0.2 , delay: 0.4, animations: {
            self.uploadPhotoButton.transform = .identity
        })
    }
    
}
