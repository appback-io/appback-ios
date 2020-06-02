//
//  AppBack+FeatureToggles.swift
//  AppBack
//
//  Created by Santiago Lozano on 1/06/20.
//

import Foundation

extension AppBack {
    
    /// Fetches the feature toggles from AppBack Core
    /// - Parameters:
    ///   - router: your appBack translation router
    ///   - completion: executable after completed
    public func getToggles(router: String, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.parameters = [.router: router]
        service.endpoint = .getFeatureToggles
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
    
    /// Stores the toggles on cache
    /// - Parameter model: AppBackTranslationsModel, optional
    internal func saveToggles(model: AppBackTogglesModel?) {
        guard let model = model else {
            return
        }
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: AppBackUserDefaultsKey.featureToggles.rawValue)
        }
    }
    
    /// Loads the toggles on memory
    internal func loadToggles() -> AppBackTogglesModel? {
        guard let data = UserDefaults.standard.object(forKey: AppBackUserDefaultsKey.featureToggles.rawValue) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(AppBackTogglesModel.self, from: data)
    }
}
