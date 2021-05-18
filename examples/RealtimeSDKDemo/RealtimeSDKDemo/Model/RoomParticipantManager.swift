//
//  RoomParticipantManager.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 5/14/21.
//

import Foundation
import UIKit
import RealtimeSDK

class RoomParticipant {
    let address: String
    let view: UIView
    init(address: String, view: UIView) {
        self.address = address
        self.view = view
    }
}

class RoomParticipantManager {
    static private(set) var participants: Array<RoomParticipant> = []

    static private let logTag = "RoomParticipantManager"

    static func addParticipant(participant: RemoteParticipant) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/1.77),
            ])

        // Add 'participant.name' label to the UIView
        let userName = UILabel(frame: CGRect(x: 20, y: view.frame.height - 5, width: 200, height: 40))
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 5
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.white,
            .shadow: shadow
        ]
        userName.attributedText = NSMutableAttributedString.init(string: participant.name ?? "", attributes: attributes)
        view.addSubview(userName)

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
}
