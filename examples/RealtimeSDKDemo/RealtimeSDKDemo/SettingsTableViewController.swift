//
//  SettingsTableViewController.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 7/1/21.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var logTag = "SettingsView"

    enum SettingType: String, CaseIterable {
        case hdVideo = "Enable HD video"
        case debugLogging = "Enable debug logs"
        case monitorQoS = "Monitor call quality"
        case preferredCodec = "Preferred video codec"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        self.clearsSelectionOnViewWillAppear = false
        Logger.debug(logTag, "Settings table VC")
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SettingType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = UITableViewCell()

        let text = SettingType.allCases[indexPath.row]
        cell.textLabel?.text = text.rawValue

        if text != .preferredCodec {
            //switch
            let switchView = UISwitch(frame: .zero)
            let savedValue = SettingsTableViewController.isSet(text)
            switchView.setOn(savedValue, animated: true)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

            cell.accessoryView = switchView
        } else {
            let codecTypes = ["VP8", "VP9"]
            let segmentedControl = UISegmentedControl(items: codecTypes)
            let savedCodecType = SettingsTableViewController.isPreferredCodecVP9()
            segmentedControl.selectedSegmentIndex = savedCodecType ? 1 : 0

            segmentedControl.frame = CGRect(x: 35, y: 200, width: 100, height: 30)
            segmentedControl.addTarget(self, action: #selector(prefferedCodecSelected(_:)), for: .valueChanged)

            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = .systemGreen
            } else {
                // Fallback on earlier versions
            }

            cell.accessoryView = segmentedControl
        }

        return cell
    }

    @objc func switchChanged(_ sender: UISwitch!) {

        let isOn = sender.isOn
        let type = SettingType.allCases[sender.tag]
        switch type {
            case .hdVideo:
                Logger.debug(logTag, "HD Video is now \(isOn ? "ON" : "OFF")")
            case .debugLogging:
                Logger.debug(logTag, "Debug logging is now \(isOn ? "ON" : "OFF")")
            case .monitorQoS:
                Logger.debug(logTag, "QoS monitoring is now \(isOn ? "ON" : "OFF")")
            case .preferredCodec:
                Logger.debug(logTag, "unexpected event")
        }
        UserDefaults.standard.setValue(isOn, forKey: "RealtimeSDKDemo_\(type.rawValue)")
    }

    @objc func prefferedCodecSelected(_ segmentedControl: UISegmentedControl) {
        var codecType = "VP9"
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            Logger.debug(logTag, "VP8 Codec selected")
            codecType = "VP8"
        case 1:
            Logger.debug(logTag, "VP9 Codec selected")
        default:
            break
        }
        UserDefaults.standard.setValue(codecType, forKey: "RealtimeSDKDemo_\(SettingType.preferredCodec.rawValue)")
    }

    static func isSet(_ type: SettingType) -> Bool {
        let isFlagSet = UserDefaults.standard.object(forKey: "RealtimeSDKDemo_\(type.rawValue)") as? Bool
        if isFlagSet == nil, type == .hdVideo {
            return true
        }
        return isFlagSet ?? false
    }

    static func isPreferredCodecVP9() -> Bool {
        if let codeType = UserDefaults.standard.object(forKey: "RealtimeSDKDemo_\(SettingType.preferredCodec.rawValue)") as? String {
            return codeType == "VP9"
        }

        // VP9 is the default codec 
        return true
    }
}
