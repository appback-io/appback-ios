//
//  AppBackAccessTokenModel.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal class AppBackAccessTokenModel: Codable {
    let accessToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }

    init(accessToken: String?) {
        self.accessToken = accessToken
    }
}

