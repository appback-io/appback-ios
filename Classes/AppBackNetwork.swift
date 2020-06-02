//
//  AppBackNetwork.swift
//  AppBack
//
//  Created by Santiago Lozano on 21/12/19.
//

import Foundation

internal typealias AppBackNetworkServiceCompletion<T: Codable> = (AppBackNetworkServiceStatus, T?) -> Void

internal class AppBackNetworkService {
    
    internal var endpoint: AppBackAPIEndpoint = .none
    internal var headers: [String: String] = [:]
    internal var method: AppBackHTTPMethod = .get
    internal var parameters: [AppBackParameter: Any] = [:]
    internal var request: URLRequest = URLRequest(url: URL(fileURLWithPath: AppBackStrings.empty))
    internal var retriable = true
    internal var retryCount = 0

    func callAppBackCore<T: Codable> (modelType: T.Type, completion: @escaping AppBackNetworkServiceCompletion<T>) {
        guard AppBack.shared.hasBeenInitialized() else {
            return
        }
        
        if endpoint != .auth, (UserDefaults.standard.value(forKey: AppBackUserDefaultsKey.baseURL.rawValue) as? String) == nil {
            self.handleUnauthorizedResponse(modelType: modelType, completion: completion)
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
                            AppBack.shared.consolePrint(AppBackErrors.notFound.rawValue)
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
            var jsonParameters: [String: Any] = [:]
            parameters.forEach { (key: AppBackParameter, value: Any) in
                jsonParameters[key.rawValue] = value
            }
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonParameters, options: .prettyPrinted)
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
        components.scheme = AppBackHTTPProtocol.https.rawValue
        var host = ""
        if endpoint == .auth {
            host = AppBackHost.apiAuth.rawValue
        } else {
            host = UserDefaults.standard.string(forKey: AppBackUserDefaultsKey.baseURL.rawValue) ?? AppBackStrings.empty
        }
        components.host = host
        components.path = endpoint.rawValue
        if components.path.contains("%@") {
            parameters.forEach({ components.path = components.path.replacingOccurrences(of: "%@\($0.key)", with: "\($0.value)") })
        }
        if parametersInURL {
            components.queryItems = parameters.compactMap({return URLQueryItem(name: $0.key.rawValue, value: "\($0.value)")})
        }
        if let url = components.url {
            return url
        } else {
            throw(AppBackNetworkServiceError.invalidURL)
        }
    }
    
    private func prepareHeaders() {
        var requestHeaders = request.allHTTPHeaderFields ?? [:]
        let token = UserDefaults.standard.string(forKey: AppBackUserDefaultsKey.bearerToken.rawValue) ?? AppBackStrings.empty
        requestHeaders[AppBackHeader.accept.rawValue] = "application/json"
        requestHeaders[AppBackHeader.authorization.rawValue] = "Bearer " + token
        requestHeaders[AppBackHeader.contentType.rawValue] = "application/json"
        requestHeaders[AppBackHeader.connection.rawValue] = "close"
        requestHeaders[AppBackHeader.userAgent.rawValue] = "AppBack iOS SDK"
        
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
        service.endpoint = .auth
        service.method = .post
        service.parameters = [AppBackParameter.key: AppBack.shared.getApiKey()]
        service.retriable =  false
        service.callAppBackCore(modelType: AppBackAccessTokenModel.self) { (status, model) in
            if status == .success {
                let baseURL = (model?.endpoint ?? AppBackStrings.empty).replacingOccurrences(of: "https://", with: AppBackStrings.empty)
                UserDefaults.standard.set(baseURL, forKey: AppBackUserDefaultsKey.baseURL.rawValue)
                UserDefaults.standard.set(model?.accessToken ?? AppBackStrings.empty, forKey: AppBackUserDefaultsKey.bearerToken.rawValue)
                self.callAppBackCore(modelType: modelType, completion: completion)
            } else {
                AppBack.shared.consolePrint(AppBackErrors.notAuthenticated.rawValue)
                completion(.fail, nil)
            }
        }
    }
}
