//
//  AppBack+EventLogs.swift
//  AppBack
//
//  Created by Santiago Lozano on 1/06/20.
//

import Foundation

extension AppBack {
    
    /// Adds an event log to AppBack Core
    /// - Parameters:
    ///   - router: your appback event router
    ///   - eventName: event name
    ///   - description: description of th event
    ///   - logLevel: enumerable from AppBackEventLogLevel
    ///   - completion: executable after execution
    public func addEventLog(router: String, eventName: String, parameters: [[String: Any]], deviceInformation: Bool = false, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        let time = Date().timeIntervalSince1970
        var parametersToSend = parameters
        if deviceInformation {
            for (key, value) in AppBackDeviceInformation.getDeviceParameter() {
                parametersToSend.append([key: value])
            }
        }
        service.parameters = [.router: router, .name: eventName, .time: time, .parameters: parametersToSend]
        service.endpoint = .addEventLog
        service.method = .post
        service.callAppBackCore(modelType: AppBackEventLogModel.self) {(status, model) in
            if status == .success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
