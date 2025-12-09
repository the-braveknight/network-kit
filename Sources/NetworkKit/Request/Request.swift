//
//  Request.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

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
///     .header(.authorization, "Bearer token123")
///     .header(.contentType, "application/json")
///     .header(.accept, "application/json")
///     .queries {
///         Query(name: "notify", value: "true")
///     }
///     .body(CreateUserInput(name: "John Doe", email: "john@example.com"))
///
/// // Build the HTTPRequest
/// let httpRequest = try createUserRequest.httpRequest(baseURL: "https://api.example.com")
/// ```
public protocol Request<ResponseBody>: Identifiable, Sendable {
    /// The type of the decoded response body this request expects.
    associatedtype ResponseBody: Decodable & Sendable

    /// A unique identifier for this request instance.
    ///
    /// Each request has a unique ID that can be used for tracking, logging, or request management.
    var id: UUID { get }

    /// The HTTP method for this request (e.g., GET, POST, PUT, DELETE).
    var method: HTTPRequest.Method { get }

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

// MARK: - HTTPRequest Builder

extension Request {
    /// Builds an `HTTPRequest` from this request and a base URL string.
    ///
    /// - Parameter baseURL: The base URL string to which the request path will be appended
    /// - Returns: A fully configured `HTTPRequest` ready to be executed
    /// - Throws: `URLError(.badURL)` if the URL cannot be constructed
    public func httpRequest(baseURL: String) throws -> HTTPRequest {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        // Append path components
        let requestPath = pathComponents.joined(separator: "/")
        if !requestPath.isEmpty {
            let basePath = urlComponents.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            urlComponents.path = "/" + [basePath, requestPath].filter { !$0.isEmpty }.joined(separator: "/")
        }

        // Add query items
        if !components.queryItems.isEmpty {
            urlComponents.queryItems = components.queryItems.map { query in
                URLQueryItem(name: query.name, value: query.value)
            }
        }

        // Extract components for HTTPRequest
        guard let scheme = urlComponents.scheme,
              let host = urlComponents.host else {
            throw URLError(.badURL)
        }

        // Build authority (host + optional port)
        var authority = host
        if let port = urlComponents.port {
            authority += ":\(port)"
        }

        // Build path with query string
        var path = urlComponents.path.isEmpty ? "/" : urlComponents.path
        if let query = urlComponents.percentEncodedQuery {
            path += "?" + query
        }

        let request = HTTPRequest(
            method: method,
            scheme: scheme,
            authority: authority,
            path: path,
            headerFields: components.headerFields
        )
        
        return request
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
    public func cURLDescription(baseURL: String) throws -> String {
        let request = try httpRequest(baseURL: baseURL)

        var curlComponents = ["$ curl -v"]
        curlComponents.append("-X \(request.method.rawValue)")

        // Add headers
        for field in request.headerFields {
            let escapedValue = field.value.replacingOccurrences(of: "\"", with: "\\\"")
            curlComponents.append("-H \"\(field.name): \(escapedValue)\"")
        }

        // Add body
        if let body = components.body {
            let httpBody = String(decoding: body, as: UTF8.self)
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            curlComponents.append("-d \"\(escapedBody)\"")
        }

        // Add URL
        let scheme = request.scheme ?? "https"
        let authority = request.authority ?? ""
        let path = request.path ?? "/"
        curlComponents.append("\"\(scheme)://\(authority)\(path)\"")

        return curlComponents.joined(separator: " \\\n")
    }
}
