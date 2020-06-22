//
//  AppBackLanguagesModel.swift
//  AppBack
//
//  Created by Juan Cardona on 22/06/20.
//

import Foundation

internal class AppBackLanguagesModel: Codable {
    let languages: [AppBackLanguageModel]?
    let message: String?
    
    init(languages: [AppBackLanguageModel]?, message: String?) {
        self.languages = languages
        self.message = message
    }
}

public class AppBackLanguageModel: Codable {
    public let name, identifier: String?

    init(name: String?, identifier: String?) {
        self.name = name
        self.identifier = identifier
    }
}
