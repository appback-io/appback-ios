//
//  AppBackEventLogModel.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal class AppBackEventLogModel: Codable {
    let code: Int?
    let message: String?
    
    init(code: Int?, message: String?) {
        self.code = code
        self.message = message
    }
}
