//
//  AppBack+Translations.swift
//  AppBack
//
//  Created by Santiago Lozano on 1/06/20.
//

import Foundation

extension AppBack {
    
    /// Obtain all languages availables in specific router
    /// - Parameter router: your appBack translation router
    public func getLanguages(router: String, completion: @escaping (_ success: Bool, _ languages: [AppBackLanguageModel]?) -> Void) {
        let service = AppBackNetworkService()
        service.method = .get
        service.parameters = [.router: router]
        service.endpoint = AppBackAPIEndpoint.getLanguages
        service.callAppBackCore(modelType: AppBackLanguagesModel.self) { (status, model) in
            if status == .success, let languages = model?.languages {
                completion(true, languages)
            } else {
                completion(false, nil)
            }
        }
    }
    
    /// Fetch the translations from AppBack Core
    /// - Parameters:
    ///   - router: your appBack translation router
    ///   - completion: executable after completed
    public func getTranslations(router: String, languageIdentifier: String, completion: @escaping (_ succeded: Bool) -> Void) {
        let service = AppBackNetworkService()
        service.method = .get
        service.parameters = [.languageIdentifier: languageIdentifier, .router: router]
        service.endpoint = AppBackAPIEndpoint.getTranslations
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
            consolePrint(String(format: AppBackErrors.defaultTranslationNotFound.rawValue, key))
        }
        return value ?? AppBackStrings.empty
    }
    
    /// Stores the translations on cache
    /// - Parameter model: AppBackTranslationsModel, optional
    internal func saveTranslations(model: AppBackTranslationsModel?) {
        guard let model = model else {
            return
        }
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: AppBackUserDefaultsKey.translations.rawValue)
        }
    }
    
    /// Loads the translations on memory
    internal func loadTranslations() -> AppBackTranslationsModel? {
        guard let data = UserDefaults.standard.object(forKey: AppBackUserDefaultsKey.translations.rawValue) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(AppBackTranslationsModel.self, from: data)
    }
}
