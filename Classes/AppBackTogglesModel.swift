//
//  AppBackTogglesModel.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal class AppBackTogglesModel: Codable {
    let toggles: [AppBackToggleModel]?

    init(toggles: [AppBackToggleModel]?) {
        self.toggles = toggles
    }
}

internal class AppBackToggleModel: Codable {
    let key, value: String?

    init(key: String?, value: String?) {
        self.key = key
        self.value = value
    }
}
