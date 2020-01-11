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
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func setTranslationsDelegate(delegate: AppBackTranslationsDelegate) {
        self.translationsDelegate = delegate
    }
    
    public func setTogglesLifetime(seconds: Int) {
        
    }
    
    public func getTranslations(router: String, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.parameters = ["router": router]
        service.endpoint = "/api/v1/translations"
        service.callAppBackCore(modelType: AppBackTranslationsModel.self) { (status, model) in
            if status == .success {
                self.saveTranslations(model: model)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func getTranslation(key: String) -> String {
        let model = loadTranslations()
        return model?.translations?.first(where: { $0.key == key})?.value ?? getDefaultTranslationValue(key: key)
    }
    
    public func getDefaultTranslationValue(key: String) -> String {
        let value = translationsDelegate?.getTranslationDefaultValue(key: key)
        if value == nil {
            consolePrint("Default translation not found for key \(key)")
        }
        return value ?? ""
    }

    public func getToggles(router: String, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.parameters = ["router": router]
        service.endpoint = "/api/v1/toggles"
        service.callAppBackCore(modelType: AppBackToggleModel.self) { (status, model) in
            if status == .success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func addEventLog(router: String, eventName: String, description: String, logLevel: AppBackEventLogLevel, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.parameters = ["router": router, "name": eventName, "description": description, "level": logLevel.rawValue]
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
    
    internal func hasBeenInitialized() -> Bool {
        let ready = apiKey != ""
        if !ready {
            consolePrint("Please initialize AppBack")
        }
        return ready
    }
    
    internal func getApiKey() -> String {
        return apiKey
    }
    
    internal func consolePrint(_ message: String) {
        print("[AppBack SDK] - \(message)")
    }
    
    internal func saveTranslations(model: AppBackTranslationsModel?) {
        guard let model = model else {
            return
        }
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: "io.appback.translations")
        }
    }
    
    internal func loadTranslations() -> AppBackTranslationsModel? {
        guard let data = UserDefaults.standard.object(forKey: "io.appback.translations") as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(AppBackTranslationsModel.self, from: data)
    }
}

public enum AppBackEventLogLevel: Int {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case fatal = 5
}
