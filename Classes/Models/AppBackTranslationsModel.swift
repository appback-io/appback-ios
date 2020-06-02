//
//  AppBackTranslationsModel.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal class AppBackTranslationsModel: Codable {
    let translations: [AppBackTranslationModel]?
    let message: String?
    
    init(translations: [AppBackTranslationModel]?, message: String?) {
        self.translations = translations
        self.message = message
    }
}

internal class AppBackTranslationModel: Codable {
    let key, value: String?

    init(key: String?, value: String?) {
        self.key = key
        self.value = value
    }
}

