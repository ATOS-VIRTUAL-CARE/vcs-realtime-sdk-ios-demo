//
//  ViewController.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 3/25/21.
//

import UIKit
import RealtimeSDK

class ViewController: UIViewController {

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var yourName: UITextField!
    @IBOutlet weak var yourCountry: UITextField!
    @IBOutlet weak var joinWithMedia: UISegmentedControl!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var createRoom: UIButton!
    @IBOutlet weak var joinRoom: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var sdkVersion: UILabel!

    var token: String?
    var mediaType: String?

    var logTag = "MainView"

    let tokenManager = RoomTokenManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        appVersion.text = "App Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "")"
        sdkVersion.text = "SDK Version: \(VCSRealtime.version)"

        // Call the 'keyboardWillShow' function when the view controller receives
        // the notification that a keyboard is going to be shown.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        // Call the 'keyboardWillHide' function when the view controller receives
        // a notification that the keyboard is going to be hidden.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        createRoom.layer.cornerRadius = 5
        joinRoom.layer.cornerRadius = 5

        mainStackView.setCustomSpacing(30, after: joinWithMedia)

        activityIndicator.style = UIActivityIndicatorView.Style.large

        Logger.debug(logTag, "RealtimeSDKDemo application initialized")
    }

    @IBAction func createRoom(_ sender: Any) {
        guard let roomName = roomName.text else {
            return
        }

        self.view.endEditing(true)

        activityIndicator.startAnimating()
        tokenManager.createRoomToken(roomName) { token in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            guard let token = token else {
                Logger.debug(self.logTag, "error in creating room")
                return
            }

            self.token = token

            Logger.debug(self.logTag, "Created room= \(roomName) with token= \(token)")
            DispatchQueue.main.async {
                Logger.debug(self.logTag, "Entering room= \(roomName)")
                self.performSegue(withIdentifier: "showCallView", sender: nil)
            }
        }
    }

    @IBAction func joinRoom(_ sender: Any) {
        guard let roomName = roomName.text else {
            return
        }

        self.view.endEditing(true)

        activityIndicator.startAnimating()
        Logger.debug(logTag, "Fetching token for room \(roomName)")
        tokenManager.getRoomToken(roomName) { (token, httpStatusCode) in

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            guard let token = token else {

                if httpStatusCode == 404 {
                    DispatchQueue.main.async {

                        let alert = UIAlertController(title: "Room Not Found", message: "The room named \"\(roomName)\" was not found.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                            Logger.debug(self.logTag, "The \"OK\" alert occurred.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    Logger.debug(self.logTag, "token error, httpStatusCode = \(httpStatusCode)")
                }
                return
            }

            self.token = token

            Logger.debug(self.logTag, "Joining room= \(roomName) with token= \(token)")
            DispatchQueue.main.async {
                Logger.debug(self.logTag, "Entering room= \(roomName)")
                self.performSegue(withIdentifier: "showCallView", sender: nil)
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, don't do anything
            return
        }

        // move the root view up by the distance of keyboard height
        let keyboardY = self.view.frame.height - keyboardSize.height
        let buttonsY = mainStackView.frame.origin.y + mainStackView.frame.height + 20
        let offset = keyboardY - buttonsY
        self.view.frame.origin.y = offset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCallView",
            let roomVC = segue.destination as? RoomViewController {
            roomVC.token = token
            if let userName = yourName.text, userName.isEmpty {
                yourName.text = randomUserName()
            }
            roomVC.name = yourName.text
            roomVC.roomName = roomName.text
            RoomParticipantManager.resetParticipantList()

            if let media = self.joinWithMedia.titleForSegment(at: self.joinWithMedia.selectedSegmentIndex) {
                roomVC.audioMedia = (media != "Video")      // Audio or Audio/Video is selected
                #if arch(arm64)
                roomVC.videoMedia = (media != "Audio")      // Video or Audio/Video is selected
                #else
                // Simulator can't capture video from camera
                roomVC.videoMedia = false
                #endif
            }
        }
    }

    // MARK: private methods
    private func randomUserName() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        let length = 4
        return "user \(String((0..<length).map{ _ in letters.randomElement()! }))"
    }
}
