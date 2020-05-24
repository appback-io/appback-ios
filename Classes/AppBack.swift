//
//  AppBack.swift
//  AppBack
//
//  Created by Santiago Lozano on 20/12/19.
//

import Foundation

public protocol AppBackTranslationsDelegate: class {
    func getTranslationDefaultValue(key: String) -> String
}

public class AppBack {
    public static let shared = AppBack()
    private var apiKey = ""
    private var translationsDelegate: AppBackTranslationsDelegate?
    
    /// Configure AppBack
    /// - Parameter apiKey: apiKey
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Define the translations delegate
    /// - Parameter delegate: AppBackTranslationsDelegate
    public func setTranslationsDelegate(delegate: AppBackTranslationsDelegate) {
        self.translationsDelegate = delegate
    }
    
    /// Define the toggles lifetime, after the lifetime the toggles will be refreshed automatically
    /// - Parameter seconds: number of seconds of lifetime
    public func setTogglesLifetime(seconds: Int) {
        
    }
    
    /// Fetch the translations from AppBack Core
    /// - Parameters:
    ///   - router: your appBack translation router
    ///   - completion: executable after completed
    public func getTranslations(router: String, lenguageIdentifier: String, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.method = .get
        service.parameters = ["language_identifier": lenguageIdentifier, "router": router]
        service.endpoint = "/api/v1/translations"
        service.callAppBackCore(modelType: AppBackTranslationsModel.self) { [weak self] (status, model) in
            guard let self = self else {
                completion(false)
                return
            }
            if status == .success {
                self.saveTranslations(model: model)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Obtain a translation from cache
    /// - Parameter key: translation key
    public func getTranslation(key: String) -> String {
        let model = loadTranslations()
        return model?.translations?.first(where: { $0.key == key})?.value ?? getDefaultTranslationValue(key: key)
    }
    
    /// Obtain the default translation value for a key
    /// - Parameter key: translation key
    public func getDefaultTranslationValue(key: String) -> String {
        let value = translationsDelegate?.getTranslationDefaultValue(key: key)
        if value == nil {
            consolePrint("Default translation not found for key \(key)")
        }
        return value ?? ""
    }
    
    /// Fetches the feature toggles from AppBack Core
    /// - Parameters:
    ///   - router: your appBack translation router
    ///   - completion: executable after completed
    public func getToggles(router: String, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.parameters = ["router": router]
        service.endpoint = "/api/v1/toggles"
        service.callAppBackCore(modelType: AppBackTogglesModel.self) { (status, model) in
            if status == .success {
                self.saveToggles(model: model)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Obtain a boolean toogle from cache
    /// - Parameter key: translation key
    public func getBoolToggle(key: String) -> Bool? {
        let model = loadToggles()
        guard let value = model?.toggles?.first(where: { $0.key == key})?.value else {
            return nil
        }
        if let boolean = Bool(value) {
            return boolean
        } else if let numericBoolean = Int(value) {
            return numericBoolean == 1 ? true : false
        }
        return nil
    }
    
    /// Obtain an integer toogle from cache
    /// - Parameter key: translation key
    public func getIntToggle(key: String) -> Int? {
        let model = loadToggles()
        guard let value = model?.toggles?.first(where: { $0.key == key})?.value else {
            return nil
        }
        return Int(value)
    }
    
    /// Obtain an integer toogle from cache
    /// - Parameter key: translation key
    public func getDoubleToggle(key: String) -> Double? {
        let model = loadToggles()
        guard let value = model?.toggles?.first(where: { $0.key == key})?.value else {
            return nil
        }
        return Double(value)
    }
    
    /// Obtain an integer toogle from cache
    /// - Parameter key: translation key
    public func getStringToggle(key: String) -> String? {
        let model = loadToggles()
        guard let value = model?.toggles?.first(where: { $0.key == key})?.value else {
            return nil
        }
        return value
    }
    
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
        service.parameters = ["router": router, "name": eventName, "time": time, "parameters": parametersToSend]
        service.endpoint = "/api/v1/eventLog"
        service.method = .post
        service.callAppBackCore(modelType: AppBackEventLogModel.self) { (status, model) in
            if status == .success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Checks for AppBacks users defined apiKey
    internal func hasBeenInitialized() -> Bool {
        let ready = apiKey != ""
        if !ready {
            consolePrint("Please initialize AppBack")
        }
        return ready
    }
    
    /// Returns the user apikey
    internal func getApiKey() -> String {
        return apiKey
    }
    
    /// Print on console formatted
    /// - Parameter message: printable message
    internal func consolePrint(_ message: String) {
        print("[AppBack SDK] - \(message)")
    }
    
    /// Stores the translations on cache
    /// - Parameter model: AppBackTranslationsModel, optional
    internal func saveTranslations(model: AppBackTranslationsModel?) {
        guard let model = model else {
            return
        }
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: "io.appback.translations")
        }
    }
    
    /// Loads the translations on memory
    internal func loadTranslations() -> AppBackTranslationsModel? {
        guard let data = UserDefaults.standard.object(forKey: "io.appback.translations") as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(AppBackTranslationsModel.self, from: data)
    }
    
    /// Stores the toggles on cache
    /// - Parameter model: AppBackTranslationsModel, optional
    internal func saveToggles(model: AppBackTogglesModel?) {
        guard let model = model else {
            return
        }
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: "io.appback.toggles")
        }
    }
    
    /// Loads the toggles on memory
    internal func loadToggles() -> AppBackTogglesModel? {
        guard let data = UserDefaults.standard.object(forKey: "io.appback.toggles") as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(AppBackTogglesModel.self, from: data)
    }
}

public enum AppBackEventLogLevel: Int {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case fatal = 5
}
