//
//  RoomViewController.swift
//  RealtimeSDKDemo
//
//  Created by Dana Brooks on 3/29/21.
//

import UIKit
import RealtimeSDK

class RoomViewController: UIViewController {

    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var leaveRoom: UIButton!
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var video: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    var token: String?
    var name: String?
    var roomName: String?
    var audioMedia: Bool = false
    var videoMedia: Bool = false

    var muteStatus: Bool = false
    var videoEnabled: Bool = false

    let logTag = "RoomView"

    let realtimeSDK = RealtimeSDKManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        leaveRoom.layer.cornerRadius = 5
        video.layer.cornerRadius = 5
        microphone.layer.cornerRadius = 5
        nameLabel.text = ""
        switchCameraButton.isHidden = !videoMedia
        #if !arch(arm64)
        video.isEnabled = false
        microphone.isEnabled = false
        #endif
        // Add a tap gesture recognizer
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))

        Logger.debug(logTag, "viewDidLoad - RoomViewController started with audio=\(audioMedia) video=\(videoMedia)")

        realtimeSDK.initialize()
        realtimeSDK.onRoomJoined = onRoomJoined
        realtimeSDK.onRoomInitFailure = onRoomInitFailure(error:)
        realtimeSDK.onParticipantJoined = onParticipantJoined(name:)
        realtimeSDK.onConnectionRejected = onConnectionRejected

        if let token = token {
            if let roomName = roomName {
                roomLabel.text = "Room: " + roomName
            }
            videoEnabled = videoMedia
            realtimeSDK.joinRoom(token, name ?? "", audioMedia, videoMedia)
        }
    }

    @IBAction func leaveRoom(_ sender: Any) {
        realtimeSDK.leaveRoom()

        self.view.window!.rootViewController?.dismiss(animated:false, completion: nil)
    }

    @IBAction func mute(_ sender: Any) {

        muteStatus = !muteStatus

        realtimeSDK.setMuteStatus(muteStatus)

        let image = muteStatus ? UIImage(named: "microphoneoff.png") : UIImage(named: "microphone.png")
        microphone.setImage(image, for: .normal)
    }

    @IBAction func video(_ sender: Any) {

        videoEnabled = !videoEnabled

        realtimeSDK.setVideoEnabled(videoEnabled)

        realtimeSDK.setVideoView(self.localVideoView, true)
        showLocalVideo(show: videoEnabled)
    }

    @IBAction func switchCamera(_ sender: Any) {
        Logger.debug(logTag, "switch camera")
        realtimeSDK.switchCamera()
        realtimeSDK.setVideoView(self.localVideoView, true)
        showLocalVideo(show: true)
    }

    @objc func handleTap() {
        Logger.debug(logTag, "tap")
    }

    func showLocalVideo(show: Bool) {
        if show {
            self.view.bringSubviewToFront(localVideoView)
            localVideoView.bringSubviewToFront(switchCameraButton)
        }
        localVideoView.isHidden = !show
        switchCameraButton.isHidden = !show

        let image = videoEnabled ? UIImage(named: "video.png") : UIImage(named: "videooff.png")
        video.setImage(image, for: .normal)
    }
}

// MARK: events from SDK
extension RoomViewController {
    func onRoomJoined() {
        Logger.debug(logTag, "onRoomJoined")

        DispatchQueue.main.async() {
            self.realtimeSDK.setVideoView(self.view, false)
            self.realtimeSDK.setVideoView(self.localVideoView, true)

            self.showLocalVideo(show: self.videoEnabled)
        }
    }

    func onRoomInitFailure(error: Error) {
        Logger.debug(logTag, "onRoomInitFailure")
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "Error Joining Room", message: "Can't join room \"\(self.roomName ?? "")\".", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                Logger.debug(self.logTag, "The \"OK\" alert occurred.")
                self.view.window!.rootViewController?.dismiss(animated:false, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func onParticipantJoined(name: String) {
        Logger.debug(logTag, "onParticipantJoined")
        DispatchQueue.main.async() {
            self.realtimeSDK.setVideoView(self.view, false)
            self.nameLabel.text = name
        }
    }

    func onConnectionRejected() {
        Logger.debug(logTag, "onConnectionRejected")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Connection Rejected", message: "Could not connect to room.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                Logger.debug(self.logTag, "The \"OK\" alert occurred.")
                self.view.window!.rootViewController?.dismiss(animated:true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
