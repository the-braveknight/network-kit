//
//  Request.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The base protocol for all HTTP network requests.
///
/// `Request` defines the structure and behavior for making HTTP requests in a type-safe, composable way.
/// Rather than conforming to this protocol directly, you typically use the concrete request types like
/// ``Get``, ``Post``, ``Put``, ``Patch``, or ``Delete``.
///
/// ## Usage
///
/// ```swift
/// // Create a GET request with path components
/// let getUserRequest = Get<User>("users", "42")
///
/// // Build a POST request with headers, query items, and body
/// let createUserRequest = Post<User>("users")
///     .headers {
///         Authorization(Bearer(token: "token123"))
///         ContentType(.json)
///         Accept(.json)
///     }
///     .queries {
///         Query(name: "notify", value: "true")
///     }
///     .body(CreateUserInput(name: "John Doe", email: "john@example.com"))
///     .timeout(30)
///
/// // Send the request using HTTPService
/// let response = try await service.send(createUserRequest)
/// print("Created user: \(response.body.name)")
/// ```
public protocol Request<ResponseBody>: Identifiable, Sendable {
    /// The type of the decoded response body this request expects.
    associatedtype ResponseBody: Decodable & Sendable

    /// A unique identifier for this request instance.
    ///
    /// Each request has a unique ID that can be used for tracking, logging, or request management.
    var id: UUID { get }

    /// The HTTP method for this request (e.g., GET, POST, PUT, DELETE).
    var method: HTTPMethod { get }

    /// The path components that make up the request URL path.
    ///
    /// These components are joined with "/" to form the request path. For example,
    /// `["users", "42", "profile"]` becomes `/users/42/profile`.
    var pathComponents: [String] { get }

    /// The configuration components for this request.
    var components: RequestComponents { get set }

    /// Creates a request with the specified path components.
    init(_ pathComponents: String...)
}

// MARK: - URLRequest Builder

extension Request {
    /// Builds a `URLRequest` from this request and a base URL.
    ///
    /// - Parameter baseURL: The base URL to which the request path will be appended
    /// - Returns: A fully configured `URLRequest` ready to be executed
    /// - Throws: ``NetworkKitError/invalidURL`` if the URL cannot be constructed
    public func urlRequest(baseURL: URL) throws -> URLRequest {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkKitError.invalidURL
        }

        // Build path by appending to existing base URL path
        let basePath = urlComponents.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestPath = pathComponents.joined(separator: "/")
        urlComponents.path = "/" + [basePath, requestPath].filter { !$0.isEmpty }.joined(separator: "/")

        // Add query items
        if !components.queryItems.isEmpty {
            urlComponents.queryItems = components.queryItems.map(\.urlQueryItem)
        }

        guard let url = urlComponents.url else {
            throw NetworkKitError.invalidURL
        }

        // Create URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = components.timeout
        urlRequest.cachePolicy = components.cachePolicy
        urlRequest.allowsCellularAccess = components.allowsCellularAccess
        urlRequest.httpBody = components.body

        // Add headers
        for header in components.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.field)
        }

        return urlRequest
    }
}

// MARK: - cURL Description

extension Request {
    /// Generates a cURL command string representation of this request.
    ///
    /// This is useful for debugging, sharing requests with others, or testing APIs manually.
    ///
    /// - Parameter baseURL: The base URL to construct the full request URL
    /// - Returns: A formatted cURL command string
    public func cURLDescription(baseURL: URL) throws -> String {
        let request = try urlRequest(baseURL: baseURL)

        guard let url = request.url, let method = request.httpMethod else {
            throw NetworkKitError.invalidURL
        }

        var components = ["$ curl -v"]
        components.append("-X \(method)")

        let headers = request.allHTTPHeaderFields ?? [:]
        for header in headers.sorted(by: { $0.key < $1.key }) {
            let escapedValue = header.value.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-H \"\(header.key): \(escapedValue)\"")
        }

        if let httpBodyData = request.httpBody {
            let httpBody = String(decoding: httpBodyData, as: UTF8.self)
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " \\\n")
    }
}
