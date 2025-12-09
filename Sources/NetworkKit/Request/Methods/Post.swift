//
//  Post.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// A POST request for creating resources on the server.
///
/// ## Usage
///
/// ```swift
/// let request = Post<User>("users")
///     .headers {
///         ContentType(.json)
///     }
///     .body(CreateUserInput(name: "John", email: "john@example.com"))
///
/// let response = try await service.load(request)
/// ```
public struct Post<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPMethod = .post
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
