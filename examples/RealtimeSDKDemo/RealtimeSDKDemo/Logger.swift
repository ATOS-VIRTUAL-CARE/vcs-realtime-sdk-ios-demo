//
//  Logger.swift
//  RealtimeSDKDemo
//
//  Created by Dana Brooks on 4/28/21.
//

import Foundation
import UIKit
import VcsRealtimeSdk

class Logger {

    static func debug(_ tag: String, _ message: String, file: NSString = #file, line: Int = #line, functionName: String = #function) {

        let msg = formatLogMessage(tag, message, .debug, file, line, functionName)
        print(msg)
    }

    static private func formatLogMessage(_ tag: String, _ message: String, _ logLevel: LogSeverity, _ file: NSString = #file, _ line: Int = #line, _ functionName: String)  -> String {

        let category = "Demo"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        let logMsg = "\(formatter.string(from: Date())) \(prettyFormatThread()) \(logLevel.rawValue) \(category) [\(tag) \(functionName)] \(message)"

        return logMsg
    }

    // MARK: Private methods
    static fileprivate func prettyFormatThread() -> String {
        let thread = String("\(Thread.current)")
        var threadString =  thread.split(separator: ">", maxSplits: 1, omittingEmptySubsequences: true)
        threadString = threadString[0].split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        return String(threadString[1])
    }

    static func logDeviceInformation() -> String {
        var output = String()

        output = output.appending("\n")
        output = output.appending("Device Information\n")
        output = output.appending("------------------\n")
        output = output.appending("App Version:   \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "")")
        output = output.appending("\n")
        output = output.appending("SDK Version:   \(RealtimeSDK.version)\n")
        output = output.appending("OS Version:    \(UIDevice.current.systemVersion)\n")
        output = output.appending("Model name:    \(UIDevice.current.model)\n")
        output = output.appending("Model ID:      \(UIDevice.current.modelName)\n")
        output = output.appending("Battery Level: ")
        UIDevice.current.isBatteryMonitoringEnabled = true
        var batteryLevel = UIDevice.current.batteryLevel
        UIDevice.current.isBatteryMonitoringEnabled = false
        if (batteryLevel < 0.0) {
            // -1.0 means battery state is UIDeviceBatteryStateUnknown
            output = output.appending("Unknown")
        } else {
            batteryLevel = batteryLevel * 100
            let battery = String(format: "%0.0f\n", batteryLevel)
            output = output.appending(battery)
        }

        return output
    }

}

extension Logger: RealtimeSDKLogProtocol {
    func logEvent(message: String) {
        print(message)
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
