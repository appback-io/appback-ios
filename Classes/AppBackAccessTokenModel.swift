//
//  AppBackAccessTokenModel.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal class AppBackAccessTokenModel: Codable {
    let accessToken: String?
    let endpoint: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case endpoint
    }

    init(accessToken: String?, endpoint: String?) {
        self.endpoint = endpoint
        self.accessToken = accessToken
    }
}

