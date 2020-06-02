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
    private var apiKey = AppBackStrings.empty
    internal var translationsDelegate: AppBackTranslationsDelegate?
    
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
    
    /// Checks for AppBacks users defined apiKey
    internal func hasBeenInitialized() -> Bool {
        let ready = apiKey != AppBackStrings.empty
        if !ready {
            consolePrint(AppBackErrors.notInitialized.rawValue)
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
        print(String(format: AppBackStrings.consoleFormat, message))
    }

}
