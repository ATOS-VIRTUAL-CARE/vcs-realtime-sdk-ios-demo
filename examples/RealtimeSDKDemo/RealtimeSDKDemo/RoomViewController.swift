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
    @IBOutlet weak var controlButtonsStack: UIStackView!
    @IBOutlet weak var participantStackView: UIStackView!

    var token: String?
    var name: String?
    var roomName: String?
    var audioMedia: Bool = false
    var videoMedia: Bool = false

    var muteStatus: Bool = false
    var videoEnabled: Bool = false

    var controlsTimer: Timer?

    let logTag = "RoomView"

    let realtimeSDK = RealtimeSDKManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        leaveRoom.layer.cornerRadius = 5
        video.layer.cornerRadius = 5
        microphone.layer.cornerRadius = 5
        switchCameraButton.isHidden = !videoMedia
        #if !arch(arm64)
        video.isEnabled = false
        microphone.isEnabled = false
        #endif

        participantStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            participantStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            participantStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])

        // Add a tap gesture recognizer
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))

        Logger.debug(logTag, "viewDidLoad - RoomViewController started with audio=\(audioMedia) video=\(videoMedia)")

        realtimeSDK.initialize()
        realtimeSDK.onRoomJoined = onRoomJoined(room:)
        realtimeSDK.onRoomInitFailure = onRoomInitFailure(error:)
        realtimeSDK.onParticipantJoined = onParticipantJoined(participant:)
        realtimeSDK.onParticipantLeft = onParticipantLeft(participant:)
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

        realtimeSDK.setLocalVideoView(self.localVideoView)
        showLocalVideo(show: videoEnabled)
    }

    @IBAction func switchCamera(_ sender: Any) {
        Logger.debug(logTag, "switch camera")
        realtimeSDK.switchCamera()
        realtimeSDK.setLocalVideoView(self.localVideoView)
        showLocalVideo(show: true)
    }

    @objc func handleTap() {
        Logger.debug(logTag, "tap - showing the control buttons")
        controlButtonsStack.setIsHidden(false, animated: true)

        // Restart the timer to hide the controls again
        startControlButtonsTimer()
    }

    func startControlButtonsTimer() {
        Logger.debug(logTag, "startControlButtonsTimer")
        self.view.bringSubviewToFront(controlButtonsStack)

        let interval:TimeInterval = 5.0
        controlsTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { (timer) in
            self.controlsTimer?.invalidate()

            self.controlButtonsStack.setIsHidden(true, animated: true)
            Logger.debug(self.logTag, "startControlButtonsTimer - control buttons are hidden now")
        }
    }

    func showLocalVideo(show: Bool) {
        if show {
            self.view.bringSubviewToFront(localVideoView)
            localVideoView.bringSubviewToFront(switchCameraButton)
        }
        Logger.debug(self.logTag, "localVideoView.subviews.count = \(localVideoView.subviews.count)")
        localVideoView.isHidden = !show
        // switchCameraButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        switchCameraButton.isHidden = !show
        let image = videoEnabled ? UIImage(named: "video.png") : UIImage(named: "videooff.png")
        Logger.debug(self.logTag, "localVideoView.frame = \(localVideoView.frame)")
        video.setImage(image, for: .normal)
        Logger.debug(self.logTag, "localVideoView.frame = \(localVideoView.frame)")
        for (index, v) in localVideoView.subviews.enumerated() {
            Logger.debug(self.logTag, "localVideoView.subviews[\(index)].frame = \(v.frame)")
        }
    }
}

// MARK: events from SDK
extension RoomViewController {
    func onRoomJoined(room: Room) {
        Logger.debug(logTag, "onRoomJoined")

        for participant in room.remoteParticipants() ?? [] {
            Logger.debug(self.logTag, "onRoomJoined - remote participant name = \(participant.name ?? "") address = \(participant.address)")

            RoomParticipantManager.participants.forEach { roomParticipant in
                addParticipantToStackView(roomParticipant)
            }
        }

        self.realtimeSDK.setLocalVideoView(self.localVideoView)
        self.showLocalVideo(show: self.videoEnabled)

        self.startControlButtonsTimer()
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

    func onParticipantJoined(participant: RemoteParticipant) {
        Logger.debug(logTag, "onParticipantJoined - name = \(participant.name ?? "") address = \(participant.address)")

        RoomParticipantManager.participants.forEach { roomParticipant in
            if roomParticipant.address == participant.address {
                addParticipantToStackView(roomParticipant)
            }
        }
    }

    func onParticipantLeft(participant: RemoteParticipant) {
        Logger.debug(logTag, "onParticipantLeft - name = \(participant.name ?? "") address = \(participant.address)")

        RoomParticipantManager.participants.forEach { roomParticipant in
            if roomParticipant.address == participant.address {
                removeParticipantFromStackView(roomParticipant)
            }
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

// MARK: participant stack view management
extension RoomViewController {
    func addParticipantToStackView(_ participant: RoomParticipant) {
        participantStackView.addArrangedSubview(participant.view)
    }

    func removeParticipantFromStackView(_ participant: RoomParticipant) {
        participant.view.removeFromSuperview()
    }
}

extension UIView {
    func setIsHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            if self.isHidden && !hidden {
                self.alpha = 0.0
                self.isHidden = false
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = hidden ? 0.0 : 1.0
            }) { (complete) in
                self.isHidden = hidden
            }
        } else {
            self.isHidden = hidden
        }
    }
}
