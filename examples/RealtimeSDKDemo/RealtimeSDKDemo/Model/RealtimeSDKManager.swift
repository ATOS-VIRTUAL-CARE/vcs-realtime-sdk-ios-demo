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

    let realtimeServer = "demo.virtualcareservices.net"

    var sdk: VCSRealtime?
    var logger = Logger()

    private(set) var room: Room?

    let logTag = "RealtimeSDKManager"

    // events to the Room View Controller
    var onRoomJoined: ((Room) -> Void)?
    var onRoomInitFailure: ((Error) -> Void)?
    var onParticipantJoined: ((RemoteParticipant) -> Void)?
    var onParticipantLeft: ((RemoteParticipant) -> Void)?
    var onConnectionRejected: (() -> Void)?

    func initialize() {
        sdk = VCSRealtime(delegate: self)
        sdk?.subscribeLogEvents(delegate: logger, severity: LogSeverity.debug)
    }

    func joinRoom(_ token: String, _ name: String, _ audio: Bool, _ video: Bool) {

        var options = VCSRealtime.RoomOptions(host: realtimeServer, name: name)
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

    func setSpeaker(_ status: Bool) {
        guard let room = room else {
            return
        }

        let currentStatus = room.isSpeaker()
        if currentStatus != status {
            let newStatus = room.toggleSpeaker()
            Logger.debug(logTag, "Speaker is now \(newStatus ? "enabled" : "disabled")")
        }
    }

    func setVideoEnabled(_ enable: Bool) {
        guard let room = room else {
            return
        }

        let currentStatus = room.hasVideo()
        if currentStatus != enable {
            let videoEnabled = room.toggleVideo(hdVideo: room.hasHdVideo())
            Logger.debug(logTag, "Local video is now \(videoEnabled ? "enabled" : "not enabled")")
        }
    }

    func switchCamera() {
        room?.switchCamera()
    }

    func setLocalVideoView(_ view: UIView) {
        guard let room = room else {
            Logger.debug(logTag, "room not ready")
            return
        }

        if let participant = room.localParticipant() {
            Logger.debug(self.logTag, "1 view.frame = \(view.frame)")
            Logger.debug(self.logTag, "1 view.subviews.count = \(view.subviews.count)")
            for (index, v) in view.subviews.enumerated() {
                Logger.debug(self.logTag, "1 view.subviews[\(index)].frame = \(v.frame)")
            }
            participant.setVideoView(view)
            Logger.debug(self.logTag, "2 view.frame = \(view.frame)")
            Logger.debug(self.logTag, "2 view.subviews.count = \(view.subviews.count)")
            for (index, v) in view.subviews.enumerated() {
                Logger.debug(self.logTag, "2 view.subviews[\(index)].frame = \(v.frame)")
            }
        }
    }

}

extension RealtimeSDKManager: VCSRealtimeProtocol {
    func onRoomInitialized(room: Room) {
        self.room = room
        room.remoteParticipants()?.forEach { participant in
            RoomParticipantManager.addParticipant(participant: participant)
        }
        onRoomJoined?(room)
    }

    func onRoomInitError(error: Error) {
        Logger.debug(logTag, "Error in room initialization, error= \(error.localizedDescription)")
        onRoomInitFailure?(error)
    }

    func onRoomLeft(room: Room) {
        guard room.roomId == self.room?.roomId else {
            Logger.debug(logTag, "Ignoring the Room Left event for  roomName = \(room.name ?? "") - user not part of it")
            return
        }

        Logger.debug(logTag, "Left the room, roomName = \(room.name ?? "")")
        self.room = nil

        RoomParticipantManager.resetParticipantList()
    }

    func onParticipantJoined(room: Room, participant: RemoteParticipant) {
        guard room.roomId == self.room?.roomId else {
            Logger.debug(logTag, "Participant joined, no matching room")
            return
        }

        Logger.debug(logTag, "Participant joined the room, participant = \(participant.address), name = \(participant.name ?? "")")
        RoomParticipantManager.addParticipant(participant: participant)

        onParticipantJoined?(participant)
    }

    func onParticipantLeft(room: Room, participant: RemoteParticipant) {
        guard room.roomId == self.room?.roomId else {
            Logger.debug(logTag, "Participant left, no matching room")
            return
        }

        Logger.debug(logTag, "Participant left the room, participant = \(participant.address), roomName = \(room.name ?? "")")
        onParticipantLeft?(participant)

        RoomParticipantManager.removeParticipant(participant: participant)
    }

    func onLocalStreamUpdated(room: Room, participant: LocalParticipant) {
        Logger.debug(logTag, "LocalStream  \(participant.stream ?? "") updated")
    }

    func onRemoteStreamUpdated(room: Room, participant: RemoteParticipant) {
        Logger.debug(logTag, "RemoteStream video: \(participant.hasVideo() ? "Enabled" : "Disabled")  mediaStrea: \(participant.stream ?? "")  ")
    }
}

