//
//  RoomParticipantManager.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 5/14/21.
//

import Foundation
import UIKit
import VcsRealtimeSdk

class RoomParticipant {
    let address: String
    let view: UIView
    init(address: String, view: UIView) {
        self.address = address
        self.view = view
    }
}

class RoomParticipantManager {

    weak static var realtimeSdkManager: RealtimeSDKManager?

    static private(set) var participants: Array<RoomParticipant> = []

    static private let logTag = "RoomParticipantManager"

    static func addParticipant(participant: RemoteParticipant) {
        let view = UIView()

        // Add 'participant.name' label to the UIView
        let userName = UILabel(frame: CGRect(x: 20, y: view.frame.height + 10, width: 200, height: 40))
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 10
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 200, green: 200, blue: 200, alpha: 0.5),
            .shadow: shadow
        ]
        userName.attributedText = NSMutableAttributedString.init(string: participant.name ?? "", attributes: attributes)
        view.addSubview(userName)


        let button = UIButton(frame: CGRect(x: 20, y: view.frame.height + 50, width: 40, height: 40))
        let messageImage = UIImage(named: "message")
        button.setImage(messageImage, for: .normal)
        button.addTarget(RoomParticipantManager.self, action: #selector(sendMessage(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = participant.address
        print("button.accessibilityIdentifier = \(String(describing: button.accessibilityIdentifier))")
        view.addSubview(button)


        view.contentMode = .scaleToFill
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.darkGray.cgColor

        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true

        let roomParticipant = RoomParticipant(address: participant.address, view: view)

        participants.append(roomParticipant)
        Logger.debug(logTag, "Participant \(participant.name ?? "") added to the list")

        participant.setVideoView(view)
    }

    static func removeParticipant(participant: RemoteParticipant) {
        if let idx = participants.firstIndex(where: { $0.address == participant.address } ) {
            participants.remove(at: idx)
        }
    }

    static func resetParticipantList() {
        participants.removeAll()
    }

    @objc static func sendMessage(_ sender: UIButton!) {

        let message = "Hi, this is test message"

        Logger.debug(logTag, "sender.accessibilityIdentifier = \(String(describing: sender.accessibilityIdentifier)) message: \(message)")

        // Create alert controller to allow user to input message
        let alert = UIAlertController(title: "Message to Send", message: "Enter text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Message"
        }

        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let userText = textField.text else { return }
            print("User text: \(userText)")

            let data = textField.text?.data(using: .utf8)
            realtimeSdkManager?.room?.sendMessageToParticipant(data!, sender.accessibilityIdentifier ?? "")
        }))

        // Present the alert box to the user
        topMostViewController().present(alert, animated: true, completion: nil)

    }

    static func topMostViewController() -> UIViewController {
        var topViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController!
    }

}
