//
//  RealtimeSDKManager.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 3/31/21.
//

import Foundation
import RealtimeSDK
import UIKit

class RealtimeSDKManager {

    var room: Room?
    var sdk: VCSRealtime?

    public var host: String?
    public var name: String?
    var token: String?
    let logTag = "RealtimeSDKManager"

    var logger = Logger()

    var remoteParticipant: RemoteParticipant?

    // events to the Room View Controller
    var onRoomJoined: (() -> Void)?
    var onRoomInitFailure: ((Error) -> Void)?
    var onParticipantJoined: ((String) -> Void)?
    var onConnectionRejected: (() -> Void)?

    func initialize() {
        sdk = VCSRealtime(delegate: self)
        sdk?.subscribeLogEvents(delegate: logger, severity: LogSeverity.debug)
    }

    func joinRoom(_ token: String, _ name: String, _ audio: Bool, _ video: Bool) {

        let roomHost = host ?? "demo.virtualcareservices.net"
        let userName = !name.isEmpty ? name : randomUserName()

        var options = VCSRealtime.RoomOptions(host: roomHost, name: userName)
        options.audio = audio
        options.video = video
        options.hdVideo = video
        options.participantInfo = ["age" : 18]

        sdk?.joinRoom(token: token, options: options) { error in
            if let error = error {
                Logger.debug(logTag, "Error in join room, error = \(error.localizedDescription)")
            }
        }
    }

    func leaveRoom() {
        room?.leave()
        room = nil
    }

    func setMuteStatus(_ status: Bool) {
        guard let room = room else {
            return
        }

        let currentStatus = room.isMuted()
        if currentStatus != status {
            let newStatus = room.toggleMute()
            Logger.debug(logTag, "User is now \(newStatus ? "muted" : "unmuted")")
        }
    }

    func setVideoEnabled(_ enable: Bool) {
        guard let room = room else {
            return
        }

        let currentStatus = room.hasVideo()
        if currentStatus != enable {
            let videoEnabled = room.toggleVideo()
            Logger.debug(logTag, "Local video is now \(videoEnabled ? "enabled" : "not enabled")")
        }
    }

    func switchCamera() {
        room?.switchCamera()
    }

    func setVideoView(_ view: UIView, _ local: Bool) {
        guard let room = room else {
            Logger.debug(logTag, "room not ready")
            return
        }

        if local, let participant = room.localParticipant() {
            participant.setVideoView(view)
        } else if !local, let remoteParticipants = room.remoteParticipants(), let participant = remoteParticipants.first {
            participant.setVideoView(view)
        }
    }

    // MARK: private methods
    private func randomUserName() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = 6
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension RealtimeSDKManager: VCSRealtimeProtocol {
    func onRoomInitialized(room: Room) {
        self.room = room
        onRoomJoined?()
    }

    func onRoomInitError(error: Error) {
        Logger.debug(logTag, "Error in room initialization, error= \(error.localizedDescription)")
        onRoomInitFailure?(error)
    }

    func onRoomLeft(room: Room) {
        if room.roomId == self.room?.roomId {
            Logger.debug(logTag, "Left the room, roomName = \(room.name ?? "")")
            self.room = nil
        } else {
            Logger.debug(logTag, "Ignoring the Room Left event for  roomName = \(room.name ?? "") - user not part of it")
        }
    }

    func onParticipantJoined(room: Room, participant: RemoteParticipant) {
        if room.roomId == self.room?.roomId {
            Logger.debug(logTag, "Participant joined the room, participant = \(participant.address), roomName = \(room.name ?? "")")
            remoteParticipant = participant
            onParticipantJoined?(participant.name ?? "")
        } else {
            Logger.debug(logTag, "Participant joined, no matching room")
        }
    }

    func onParticipantLeft(room: Room, participant: RemoteParticipant) {
        if room.roomId == self.room?.roomId {
            Logger.debug(logTag, "Participant left the room, participant = \(participant.address), roomName = \(room.name ?? "")")
            if participant.address == (remoteParticipant?.address ?? "") {
            }
        } else {
            Logger.debug(logTag, "Participant left, no matching room")
        }
    }

    func onLocalStreamUpdated(room: Room, participant: LocalParticipant) {
        let mediaStream = participant.stream
        Logger.debug(logTag, "LocalStream  \(mediaStream ?? "") updated")
    }

    func onRemoteStreamUpdated(room: Room, participant: RemoteParticipant) {
        let mediaStream = participant.stream
        Logger.debug(logTag, "RemoteStream video: \(participant.hasVideo() ? "Enabled" : "Disabled")  mediaStrea: \(mediaStream ?? "")  ")

        if remoteParticipant == nil || remoteParticipant?.address == participant.address {
            remoteParticipant = participant
        }
    }
}

