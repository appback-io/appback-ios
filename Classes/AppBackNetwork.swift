//
//  AppBackNetwork.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
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

internal typealias AppBackNetworkServiceCompletion<T: Codable> = (AppBackNetworkServiceStatus, T?) -> Void

internal class AppBackNetworkService {
    internal var endpoint = ""
    internal var headers: [String: String] = [:]
    internal var method: AppBackHTTPMethod = .get
    internal var parameters: [String: Any] = [:]
    internal var request: URLRequest = URLRequest(url: URL(fileURLWithPath: ""))
    internal var retriable = true
    internal var retryCount = 0

    func callAppBackCore<T: Codable> (modelType: T.Type, completion: @escaping AppBackNetworkServiceCompletion<T>) {
        guard AppBack.shared.hasBeenInitialized() else {
            return
        }
        do {
            try prepareRequest()
        } catch {
            completion(.fail, nil)
        }
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 30
            return configuration
        }()
        let task = URLSession(configuration: configuration).dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                do {
                    let responseCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    guard error == nil else {
                        completion(.fail, nil)
                        return
                    }
                    if let availableData = data {
                        if responseCode == 401 {
                            self.handleUnauthorizedResponse(modelType: modelType, completion: completion)
                        } else if (200...299).contains(responseCode) {
                            try self.handleSuccessResponse(modelType: modelType, data: availableData, completion: completion)
                        } else if responseCode == 404 {
                            AppBack.shared.consolePrint("Resource couldn't be found, please check the parameters")
                            completion(.notFound, nil)
                        } else {
                            completion(.fail, nil)
                        }
                    } else {
                        self.handleRetry(modelType: modelType, completion: completion)
                    }
                } catch {
                    completion(.fail, nil)
                }
            }
        }
        task.resume()
    }

    private func preparePOSTParameters() throws {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            throw(AppBackNetworkServiceError.notParsedParameters)
        }
    }

    private func prepareRequest() throws {
        do {
            var url = try prepareURL()
            request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            switch method {
            case .get:
                url = try prepareURL(parametersInURL: true)
            case .delete, .patch, .post, .put:
                try preparePOSTParameters()
            }
            request.url = url
            prepareHeaders()
        } catch let error {
            throw(error)
        }
    }

    private func prepareURL(parametersInURL: Bool = false) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        let host = "appback.io"
        components.host = host
        components.path = endpoint
        if components.path.contains("%@") {
            parameters.forEach({ components.path = components.path.replacingOccurrences(of: "%@\($0.key)", with: "\($0.value)") })
        }
        if parametersInURL {
            components.queryItems = parameters.compactMap({return URLQueryItem(name: $0.key, value: "\($0.value)")})
        }
        if let url = components.url {
            return url
        } else {
            throw(AppBackNetworkServiceError.invalidURL)
        }
    }
    
    private func prepareHeaders() {
        var requestHeaders = request.allHTTPHeaderFields ?? [:]
        let token = UserDefaults.standard.string(forKey: "io.appback.bearerToken") ?? ""
        requestHeaders["Accept"] = "application/json"
        requestHeaders["Authorization"] = "Bearer " + token
        requestHeaders["Content-type"] = "application/json"
        requestHeaders["Connection"] = "close"
        requestHeaders["User-Agent"] = ""
        
        headers.forEach { (key: String, value: String) in
            requestHeaders[key] = value
        }
        request.allHTTPHeaderFields = requestHeaders
    }
    
    private func handleRetry<T: Codable> (modelType: T.Type, completion: @escaping AppBackNetworkServiceCompletion<T>) {
        if retryCount < 3  && retriable {
            retryCount += 1
            callAppBackCore(modelType: modelType, completion: completion)
        } else {
            completion(.fail, nil)
        }
    }
    
    private func handleSuccessResponse<T: Codable>(modelType: T.Type, data: Data, completion: @escaping AppBackNetworkServiceCompletion<T>) throws {
        if retryCount != 0 {
            retryCount = 0
        }
        do {
            let decodedData = try JSONDecoder().decode(modelType.self, from: data)
            completion(.success, decodedData)
        } catch {
            throw(AppBackNetworkServiceError.decodingError)
        }
    }
    
    private func handleUnauthorizedResponse<T: Codable> (modelType: T.Type, completion: @escaping AppBackNetworkServiceCompletion<T>) {
        let service = AppBackNetworkService()
        service.endpoint = "/api/token"
        service.method = .get
        service.parameters = ["key": AppBack.shared.getApiKey()]
        service.retriable =  false
        service.callAppBackCore(modelType: AppBackAccessTokenModel.self) { (status, model) in
            if status == .success {
                UserDefaults.standard.set(model?.accessToken ?? "", forKey: "io.appback.bearerToken")
                self.callAppBackCore(modelType: modelType, completion: completion)
            } else {
                AppBack.shared.consolePrint("Couldn't authenticate with AppBack Core, please check you ApiKey")
                completion(.fail, nil)
            }
        }
    }
}
