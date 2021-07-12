//
//  RoomViewController.swift
//  RealtimeSDKDemo
//
//  Created by Dana Brooks on 3/29/21.
//

import UIKit
import VcsRealtimeSdk

class RoomViewController: UIViewController {

    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var leaveRoom: UIButton!
    @IBOutlet weak var speaker: UIButton!
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
    var speakerStatus: Bool = false
    var videoEnabled: Bool = false

    var controlsTimer: Timer?

    // Set the status bar text to light so it can be seen against the
    // black background.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    let logTag = "RoomView"

    let realtimeSDK = RealtimeSDKManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        leaveRoom.layer.cornerRadius = 5
        video.layer.cornerRadius = 5
        microphone.layer.cornerRadius = 5
        speaker.layer.cornerRadius = 5
        switchCameraButton.isHidden = !videoMedia
        leaveRoom.setBackgroundImage(UIImage(named: "hangup"), for: .normal)
        #if !arch(arm64)
        video.isEnabled = false
        microphone.isEnabled = false
        #endif

        // Add a tap gesture recognizer
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))

        // Set up the pan gesture recognizer to allow moving the local video view
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.localVideoView.addGestureRecognizer(gestureRecognizer)

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

        startControlButtonsTimer()
    }

    @IBAction func video(_ sender: Any) {

        videoEnabled = !videoEnabled

        realtimeSDK.setVideoEnabled(videoEnabled)

        realtimeSDK.setLocalVideoView(self.localVideoView)
        showLocalVideo(show: videoEnabled)

        startControlButtonsTimer()
    }

    @IBAction func speaker(_ sender: Any) {

        speakerStatus = !speakerStatus

        realtimeSDK.setSpeaker(speakerStatus)

        if speakerStatus {
            speaker.isSelected = true
        } else {
            speaker.isSelected = false
        }

        startControlButtonsTimer()
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
        controlsTimer?.invalidate()
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

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {

            let translation = gestureRecognizer.translation(in: self.view)

            // Get the position of the local video view
            let x = gestureRecognizer.view?.frame.origin.x ?? 0
            let y = gestureRecognizer.view?.frame.origin.y ?? 0

            // Get the size of the local video view
            let viewWidth = gestureRecognizer.view?.frame.width ?? 0
            let viewHeight = gestureRecognizer.view?.frame.height ?? 0

            // Get the screen size
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height

            // Check the top bounds
            if x < 0 {
                gestureRecognizer.view?.frame.origin.x = 0
                return
            }

            // Check the left bounds
            if y < 0 {
                gestureRecognizer.view?.frame.origin.y = 0
                return
            }

            // Check the right bounds
            if x + viewWidth > screenWidth {
                gestureRecognizer.view?.frame.origin.x = screenWidth - viewWidth
                return
            }

            // Check the bottom bounds
            if y + viewHeight > screenHeight {
                gestureRecognizer.view?.frame.origin.y = screenHeight - viewHeight
                return
            }

            // If we're this far, move the view
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)

            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
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
