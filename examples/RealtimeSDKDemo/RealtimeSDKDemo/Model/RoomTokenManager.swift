//
//  RoomTokenManager.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 3/31/21.
//

import Foundation

class RoomTokenManager {
    let serverName = "sdk-demo.virtualcareservices.net"

    private var restTransactions: [UUID:RestManager]?
    private let logTag = "RealtimeSDKManager"

    func getRoomToken(_ roomName: String, completion: @escaping (String?, Int) -> Void) {

        guard !roomName.isEmpty else {
            Logger.debug(logTag, "Room name is empty")
            completion(nil, 0)
            return
        }

        let url = URL(string: "https://\(serverName)/api/room")
        let rest = RestManager()
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.requestHttpHeaders.add(value: "*/*", forKey: "accept")
        rest.urlQueryParameters.add(value: roomName, forKey: "name")

        addRestTransaction(rest: rest)
        rest.makeRequest(toURL: url!, withHttpMethod: .get) { (results) in
            self.releaseRestTransaction(rest: rest)

            guard let response = results.response else {
                Logger.debug(self.logTag, "No response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
                completion(nil, 0)
                return
            }

            switch response.httpStatusCode {
                case 200:
                    Logger.debug(self.logTag, "200 response from GET request for \(url?.absoluteString ?? "<unknown URL>")")

                    if let data = results.data,
                       let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any?>,
                       let room = jsonDictionary["room"] as? Dictionary<String, Any?>,
                       let token = room["token"] as? String {
                        Logger.debug(self.logTag, "Token found for room = \(roomName) token = \(token)")
                        completion(token, 0)
                        return
                    } else {
                        Logger.debug(self.logTag, "token not found for room = \(roomName), httpStatusCode = \(results.response?.httpStatusCode ?? 0)")
                    }

                case 404:
                    Logger.debug(self.logTag, "Error getting token, 404 response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
                    completion(nil, 404)
                    return

                default:
                    Logger.debug(self.logTag, "Unexpected response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
            }
            completion(nil, 0)
        }
    }

    func createRoomToken(_ roomName: String, completion: @escaping (String?, String?) -> Void) {

        guard !roomName.isEmpty else {
            Logger.debug(logTag, "Room name is empty")
            completion(nil, "Room name is empty")
            return
        }

        guard let roomNameEscaped = roomName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            Logger.debug(logTag, "Escaped Room name is empty")
            completion(nil, "Escaped Room name is empty")
            return
        }

        let url = URL(string: "https://\(serverName)/api/room")
        let rest = RestManager()
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.requestHttpHeaders.add(value: "*/*", forKey: "accept")
        rest.httpBody = "{ \"name\": \"\(roomNameEscaped)\"}".data(using: .utf8)

        addRestTransaction(rest: rest)
        rest.makeRequest(toURL: url!, withHttpMethod: .post) { (results) in
            self.releaseRestTransaction(rest: rest)

            guard let response = results.response else {
                Logger.debug(self.logTag, "No response from POST request for \(url?.absoluteString ?? "<unknown URL>")")
                completion(nil, "No response from POST request for \(url?.absoluteString ?? "<unknown URL>")")
                return
            }

            var error = ""
            switch response.httpStatusCode {
                case 200:
                    Logger.debug(self.logTag, "200 response from POST request for \(url?.absoluteString ?? "<unknown URL>")")

                    if let data = results.data,
                       let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any?>,
                       let room = jsonDictionary["room"] as? Dictionary<String, Any?>,
                       let token = room["token"] as? String {

                        completion(token, nil)
                        return
                    } else {
                        Logger.debug(self.logTag, "token not found for room = \(roomName), httpStatusCode = \(results.response?.httpStatusCode ?? 0)")
                    }
                case 409:
                    if let data = results.data, let errorText = String(data: data, encoding: .utf8) {
                        Logger.debug(self.logTag, "Unexpected response from POST request for \(url?.absoluteString ?? "<unknown URL>") httpStatusCode: \(response.httpStatusCode) error: \(errorText)")
                        error = errorText
                    } else {
                        Logger.debug(self.logTag, "Unexpected 409 response from POST request for \(url?.absoluteString ?? "<unknown URL>") httpStatusCode: \(response.httpStatusCode)")
                        error = "Unexpected 409 response from POST request"
                    }
                default:
                    Logger.debug(self.logTag, "Unexpected response from POST request for \(url?.absoluteString ?? "<unknown URL>") httpStatusCode: \(response.httpStatusCode)")
                    error = "Unexpected response from POST request"
            }
            completion(nil, error)
        }
    }

    private func addRestTransaction(rest: RestManager) {
        restTransactions?[rest.restTransactionId] = rest
    }

    private func releaseRestTransaction(rest: RestManager) {
        restTransactions?.removeValue(forKey: rest.restTransactionId)
    }

}
