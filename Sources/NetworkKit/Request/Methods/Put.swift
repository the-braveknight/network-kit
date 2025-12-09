//
//  Put.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// A PUT request for replacing resources on the server.
///
/// ## Usage
///
/// ```swift
/// let request = Put<User>("users", "42")
///     .headers {
///         ContentType(.json)
///     }
///     .body(UpdateUserInput(name: "John Updated"))
///
/// let response = try await service.load(request)
/// ```
public struct Put<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPMethod = .put
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
