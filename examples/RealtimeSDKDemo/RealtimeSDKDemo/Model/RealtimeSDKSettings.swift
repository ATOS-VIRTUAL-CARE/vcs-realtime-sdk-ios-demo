//
//  RealtimeSDKSettings.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 7/23/21.
//

import Foundation

class RealtimeSDKSettings {

    /// Application server provides room tokens and VCS domain name based on "Room name"  &  API key
    static private let applicationServer = "sdk-snapshot.virtualcareservices.net"
    static private let serverUsername = ""
    static private let serverPassword = ""

    static var server: String {
        get {
            let address = UserDefaults.standard.object(forKey: "RealtimeSDKDemo_\(SettingsTableViewController.SettingType.serverAddress.rawValue)") as? String
            return address ?? RealtimeSDKSettings.applicationServer
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: "RealtimeSDKDemo_\(SettingsTableViewController.SettingType.serverAddress.rawValue)")
        }
    }

    static var user: String {
        get {
            let name = UserDefaults.standard.object(forKey: "RealtimeSDKDemo_\(SettingsTableViewController.SettingType.userName.rawValue)") as? String
            return name ?? RealtimeSDKSettings.serverUsername
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: "RealtimeSDKDemo_\(SettingsTableViewController.SettingType.userName.rawValue)")
        }
    }

    static var password: String {
        get {
            let pass = UserDefaults.standard.object(forKey: "RealtimeSDKDemo_\(SettingsTableViewController.SettingType.password.rawValue)") as? String
            return pass ?? RealtimeSDKSettings.serverPassword
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: "RealtimeSDKDemo_\(SettingsTableViewController.SettingType.password.rawValue)")
        }
    }
}
