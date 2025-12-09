//
//  Options.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// An OPTIONS request for retrieving supported HTTP methods for a resource.
///
/// OPTIONS is used to describe the communication options for the target resource.
/// This is commonly used for CORS preflight requests.
///
/// ## Usage
///
/// ```swift
/// let request = Options<Data>("users")
///
/// let response = try await service.load(request)
/// print("Allowed: \(response.originalResponse.value(forHTTPHeaderField: "Allow"))")
/// ```
public struct Options<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPMethod = .options
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
