//
//  RoomTokenManager.swift
//  RealtimeSDKDemo
//
//  Created by Phani Yarlagadda on 3/31/21.
//

import Foundation

class RoomTokenManager {

    private var restTransactions: [UUID:RestManager]?
    private let logTag = "RealtimeSDKManager"
    private var authorizationRequired = false

    func getRoomToken(_ roomName: String, completion: @escaping (String?, String?, Int) -> Void) {

        guard !roomName.isEmpty else {
            Logger.debug(logTag, "Room name is empty")
            completion(nil, nil, 0)
            return
        }

        let url = URL(string: "https://\(RealtimeSDKSettings.applicationServer)/api/room")
        let rest = RestManager()
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.requestHttpHeaders.add(value: "*/*", forKey: "accept")
        rest.urlQueryParameters.add(value: roomName, forKey: "name")

        addRestTransaction(rest: rest)
        rest.makeRequest(toURL: url!, withHttpMethod: .get) { (results) in
            self.releaseRestTransaction(rest: rest)

            guard let response = results.response else {
                Logger.debug(self.logTag, "No response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
                completion(nil, nil, 0)
                return
            }

            switch response.httpStatusCode {
                case 200:
                    Logger.debug(self.logTag, "200 response from GET request for \(url?.absoluteString ?? "<unknown URL>")")

                    if let data = results.data,
                       let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any?>,
                       let room = jsonDictionary["room"] as? Dictionary<String, Any?>,
                       let token = room["token"] as? String,
                       let domain = jsonDictionary["domain"] as? String {
                        Logger.debug(self.logTag, "Token found for room = \(roomName) domain = \(domain) token = \(token) ")
                        completion(domain, token, 0)
                        return
                    } else {
                        Logger.debug(self.logTag, "token not found for room = \(roomName), httpStatusCode = \(results.response?.httpStatusCode ?? 0)")
                    }

                case 404:
                    Logger.debug(self.logTag, "Error getting token, 404 response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
                    completion(nil, nil, 404)
                    return

                default:
                    Logger.debug(self.logTag, "Unexpected response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
            }
            completion(nil, nil, 0)
        }
    }

    func getConfig(completion: @escaping (String?, String?, Int) -> Void) {

        let url = URL(string: "https://\(RealtimeSDKSettings.applicationServer)/api/config")
        let rest = RestManager()
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.requestHttpHeaders.add(value: "*/*", forKey: "accept")

        addRestTransaction(rest: rest)
        rest.makeRequest(toURL: url!, withHttpMethod: .get) { (results) in
            self.releaseRestTransaction(rest: rest)

            guard let response = results.response else {
                Logger.debug(self.logTag, "No response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
                completion(nil, nil, 0)
                return
            }

            switch response.httpStatusCode {
                case 200:
                    Logger.debug(self.logTag, "200 response from GET request for \(url?.absoluteString ?? "<unknown URL>")")

                    if let data = results.data,
                       let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any?>,
                       let server = jsonDictionary["VCS_HOST"] as? String,
                       let auth = jsonDictionary["AUTH_TYPE"] as? String {
                        Logger.debug(self.logTag, "server = \(server) auth = \(auth)")
                        if auth == "BASIC_AUTH" {
                            self.authorizationRequired = true
                        }
                        completion(server, auth, 0)
                        return
                    } else {
                        let code = results.response?.httpStatusCode ?? 0
                        Logger.debug(self.logTag, "Unable to retrieve config from server, httpStatusCode = \(code)")
                    }

                case 404:
                    Logger.debug(self.logTag, "Error getting config, 404 response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
                    completion(nil, nil, 404)
                    return

                default:
                    Logger.debug(self.logTag, "Unexpected response from GET request for \(url?.absoluteString ?? "<unknown URL>")")
            }
            completion(nil, nil, 0)
        }
    }

    func createRoomToken(_ roomName: String, completion: @escaping (String?, String?, String?) -> Void) {

        guard !roomName.isEmpty else {
            Logger.debug(logTag, "Room name is empty")
            completion(nil, nil, "Room name is empty")
            return
        }

        let url = URL(string: "https://\(RealtimeSDKSettings.applicationServer)/api/room")
        let rest = RestManager()
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.requestHttpHeaders.add(value: "*/*", forKey: "accept")
        if self.authorizationRequired {
            let authorization = "\(RealtimeSDKSettings.serverUsername):\(RealtimeSDKSettings.serverPassword)".data(using: .utf8)
            if let encodedAuthorization = authorization?.base64EncodedString() {
                rest.requestHttpHeaders.add(value: "Basic \(encodedAuthorization)", forKey: "authorization")
                Logger.debug(logTag, "Including encoded authorization header")
            }
        }

        rest.httpBody = "{ \"name\": \"\(roomName)\"}".data(using: .utf8)

        addRestTransaction(rest: rest)
        rest.makeRequest(toURL: url!, withHttpMethod: .post) { (results) in
            self.releaseRestTransaction(rest: rest)

            guard let response = results.response else {
                Logger.debug(self.logTag, "No response from POST request for \(url?.absoluteString ?? "<unknown URL>")")
                completion(nil, nil, "No response from POST request for \(url?.absoluteString ?? "<unknown URL>")")
                return
            }

            var error = ""
            switch response.httpStatusCode {
                case 200:
                    Logger.debug(self.logTag, "200 response from POST request for \(url?.absoluteString ?? "<unknown URL>")")

                    if let data = results.data,
                       let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any?>,
                       let room = jsonDictionary["room"] as? Dictionary<String, Any?>,
                       let token = room["token"] as? String,
                       let domain = jsonDictionary["domain"] as? String {
                        Logger.debug(self.logTag, "Token for room = \(roomName) domain = \(domain) token = \(token) ")

                        completion(domain, token, nil)
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
            completion(nil, nil, error)
        }
    }

    private func addRestTransaction(rest: RestManager) {
        restTransactions?[rest.restTransactionId] = rest
    }

    private func releaseRestTransaction(rest: RestManager) {
        restTransactions?.removeValue(forKey: rest.restTransactionId)
    }

}
