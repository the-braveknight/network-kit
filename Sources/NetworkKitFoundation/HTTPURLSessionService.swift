//
//  HTTPURLSessionService.swift
//  NetworkKitFoundation
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import NetworkKit
import HTTPTypes

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A URLSession-based implementation of ``HTTPService``.
///
/// `HTTPURLSessionService` uses Foundation's `URLSession` to execute HTTP requests.
/// This is the standard implementation for Apple platforms and Linux.
///
/// ## Implementation Example
///
/// ```swift
/// struct MyAPIService: HTTPURLSessionService {
///     let baseURL = URL(string: "https://api.example.com")!
///
///     // session, encoder, and decoder have default implementations
///     // but you can override them if needed:
///     let session: URLSession = {
///         let configuration = URLSessionConfiguration.default
///         configuration.timeoutIntervalForRequest = 30
///         return URLSession(configuration: configuration)
///     }()
///
///     var encoder: JSONEncoder {
///         let encoder = JSONEncoder()
///         encoder.keyEncodingStrategy = .convertToSnakeCase
///         return encoder
///     }
///
///     var decoder: JSONDecoder {
///         let decoder = JSONDecoder()
///         decoder.keyDecodingStrategy = .convertFromSnakeCase
///         return decoder
///     }
/// }
/// ```
///
/// ## Usage Example
///
/// ```swift
/// let service = MyAPIService()
///
/// // Load a simple GET request
/// let request = Get<User>("/users/42")
/// let response = try await service.load(request)
/// print("User: \(try response.body.name)")
/// ```
public protocol HTTPURLSessionService: HTTPService {
    /// The base URL for all requests sent through this service.
    var baseURL: URL { get }

    /// The `URLSession` used to execute network requests.
    var session: URLSession { get }
}

// MARK: - Default Implementations

extension HTTPURLSessionService {
    public var session: URLSession {
        .shared
    }
}

extension HTTPURLSessionService where Encoder == JSONEncoder {
    public var encoder: JSONEncoder {
        JSONEncoder()
    }
}

extension HTTPURLSessionService where Decoder == JSONDecoder {
    public var decoder: JSONDecoder {
        JSONDecoder()
    }
}

// MARK: - Load Implementation

extension HTTPURLSessionService {
    public func load<R: Request>(_ request: R) async throws -> Response<R.ResponseBody> {
        let urlRequest = try buildURLRequest(for: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let responseDecoder = request.components.decoder ?? decoder
        return Response(
            data: data,
            status: HTTPResponse.Status(code: httpResponse.statusCode),
            headerFields: httpResponse.httpFields,
            decoder: responseDecoder
        )
    }

    private func buildURLRequest<R: Request>(for request: R) throws -> URLRequest {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw URLError(.badURL)
        }

        // Append path components
        let requestPath = request.pathComponents.joined(separator: "/")
        if !requestPath.isEmpty {
            let basePath = urlComponents.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            urlComponents.path = "/" + [basePath, requestPath].filter { !$0.isEmpty }.joined(separator: "/")
        }

        // Add query items
        if !request.components.queryItems.isEmpty {
            urlComponents.queryItems = request.components.queryItems.map { query in
                URLQueryItem(name: query.name, value: query.value)
            }
        }

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        let requestEncoder = request.components.encoder ?? encoder
        urlRequest.httpBody = try request.components.body?.encode(using: requestEncoder)

        // Set headers
        for field in request.components.headerFields {
            urlRequest.setValue(field.value, forHTTPHeaderField: field.name.rawName)
        }

        return urlRequest
    }
}

// MARK: - HTTPURLResponse Extension

extension HTTPURLResponse {
    var httpFields: HTTPFields {
        var fields = HTTPFields()
        for (key, value) in allHeaderFields {
            if let name = key as? String, let value = value as? String {
                if let fieldName = HTTPField.Name(name) {
                    fields[fieldName] = value
                }
            }
        }
        return fields
    }
}
