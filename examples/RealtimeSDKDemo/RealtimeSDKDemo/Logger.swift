//
//  Logger.swift
//  RealtimeSDKDemo
//
//  Created by Dana Brooks on 4/28/21.
//

import Foundation
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

}

extension Logger: RealtimeSDKLogProtocol {
    func logEvent(message: String) {
        print(message)
    }
}
