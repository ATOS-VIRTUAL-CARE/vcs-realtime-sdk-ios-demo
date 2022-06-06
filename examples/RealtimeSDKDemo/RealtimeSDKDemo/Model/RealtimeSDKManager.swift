//
//  RealtimeSDKManager.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 3/31/21.
//

import Foundation
import VcsRealtimeSdk
import UIKit

class RealtimeSDKManager {

    var sdk: RealtimeSDK?
    var countryCode = "US"
    var logger = Logger()

    private(set) var room: Room?

    let logTag = "RealtimeSDKManager"

    // events to the Room View Controller
    var onRoomJoined: ((Room) -> Void)?
    var onRoomInitFailure: ((Error) -> Void)?
    var onParticipantJoined: ((RemoteParticipant) -> Void)?
    var onParticipantLeft: ((RemoteParticipant) -> Void)?
    var onConnectionRejected: (() -> Void)?
    var onLocalStreamUpdated: ((Bool) -> Void)?
    var onTextMessageReceived: ((String, String) -> Void)?

    func initialize() {
        sdk = RealtimeSDK(delegate: self)

        let logSeverity: LogSeverity = SettingsTableViewController.isSet(.debugLogging) ? .verbose : .debug
        sdk?.subscribeLogEvents(delegate: logger, severity: logSeverity)
    }

    func dismiss() {
        onRoomJoined = nil
        onRoomInitFailure = nil
        onParticipantJoined = nil
        onParticipantLeft = nil
        onConnectionRejected = nil
        onLocalStreamUpdated = nil
    }

    func joinRoom(_ domain: String, _ token: String, _ name: String, _ audio: Bool, _ video: Bool) {

        sdk?.advanced.monitorCallQuality = SettingsTableViewController.isSet(.monitorQoS)
        sdk?.advanced.preferredVideoCodec = RealtimeSDK.Settings.Codec(rawValue: SettingsTableViewController.preferredVideoCodec ?? "VP9") ?? .vp9

        var options = RealtimeSDK.RoomOptions(host: domain, name: name)
        options.audio = audio
        options.video = video
        if DeviceCapabilities.hdVideo() {
            options.hdVideo = video && SettingsTableViewController.isSet(.hdVideo)
        }
        options.participantInfo = ["country": countryCode]

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

extension RealtimeSDKManager: RealtimeSDKProtocol {
    func onRoomUpdated(room: Room) {

    }

    func onActiveSpeakerUpdated(room: Room, activeSpeakers: [String]) {

    }

    func onRemoteAudioStream(room: Room, connected: Bool) {

    }


    func onRoomInitialized(room: Room) {
        self.room = room
        room.remoteParticipants()?.forEach { participant in
            RoomParticipantManager.addParticipant(participant: participant)
        }
        onRoomJoined?(room)
        room.scaleDownVideo(enable: SettingsTableViewController.isSet(.scaleDownVideo), connectionId: nil, width: nil)
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

        dismiss()
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
        self.onLocalStreamUpdated?(room.hasVideo())
    }

    func onRemoteStreamUpdated(room: Room, participant: RemoteParticipant) {
        Logger.debug(logTag, "RemoteStream video: \(participant.hasVideo() ? "Enabled" : "Disabled")  mediaStrea: \(participant.stream ?? "")  ")
    }

    func onMessageReceived(address: String, message: Data) {
        let remoteParticipantName = room?.remoteParticipants()?.filter({ $0.address == address }).first?.name

        onTextMessageReceived?(remoteParticipantName ?? "", String(decoding: message, as: UTF8.self))
    }
    func onDataChannelOpen(address: String) {
        Logger.debug(logTag, "onDataChannelOpen  participant address: \(address)")
    }

    func onDataChannelClosed(address: String) {
        Logger.debug(logTag, "onDataChannelClosed  participant address: \(address)")
    }
}

