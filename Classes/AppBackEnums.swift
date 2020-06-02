//
//  AppBackEnums.swift
//  AppBack
//
//  Created by Santiago Lozano on 1/06/20.
//

import Foundation

internal enum AppBackHTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
}
internal enum AppBackNetworkServiceError: Error {
    case decodingError
    case invalidURL
    case notKnownResponseCode
    case notParsedParameters
    case refreshTokenFailed
    case retryFailed
    case unpreparableRequest
}

internal enum AppBackNetworkServiceStatus: Int {
    case success
    case fail
    case notFound
}
internal enum AppBackHTTPProtocol: String {
    case http = "http"
    case https = "https"
}
internal enum AppBackHost: String {
    case apiAuth = "api-auth.appback.io"
}
internal enum AppBackAPIEndpoint: String {
    case getFeatureToggles = "/api/v1/toggles"
    case getTranslations = "/api/v1/translations"
    case addEventLog = "/api/v1/eventLog"
    case none = ""
    case auth = "/api/token"
}

internal enum AppBackUserDefaultsKey: String {
    case baseURL = "io.appback.baseURL"
    case bearerToken = "io.appback.bearerToken"
    case translations = "io.appback.translations"
    case featureToggles = "io.appback.toggles"
}

internal enum AppBackErrors: String {
    case notFound = "Resource couldn't be found, please check the parameters"
    case notAuthenticated = "Couldn't authenticate with AppBack Core, please check you ApiKey"
    case notInitialized = "Please initialize AppBack"
    case defaultTranslationNotFound = "Default translation not found for key %@"
}

internal enum AppBackHeader: String {
    case accept = "Accept"
    case authorization = "Authorization"
    case contentType = "Content-type"
    case connection = "Connection"
    case userAgent = ""
}

internal enum AppBackParameter: String {
    case router
    case key
    case name
    case time
    case parameters
    case languageIdentifier = "language_identifier"
}

internal enum AppBackEventParameter: String {
    case device = "_device"
    case systemVersion = "_system_version"
    case appVersion = "_app_version"
    case orientation = "_orientation"
    case deviceID = "_device_ID"
    case batteryLevel = "_battery_level"
    case carrier = "_carrier"
    case storage = "_storage"
    case connectionType = "_connection_type"
}

internal struct AppBackStrings {
    static let consoleFormat = "[AppBack SDK] - %@"
    static let empty = ""
}
