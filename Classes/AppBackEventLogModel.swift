//
//  AppBackEventLogModel.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal class AppBackEventLogModel: Codable {
    let code: Int?
    
    init(code: Int?) {
        self.code = code
    }
}
