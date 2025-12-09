//
//  Put.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A PUT request for replacing resources on the server.
///
/// ## Usage
///
/// ```swift
/// let request = Put<User>("users", "42")
///     .header(.contentType, "application/json")
///     .body(UpdateUserInput(name: "John Updated"))
///
/// let response = try await service.load(request)
/// ```
public struct Put<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPRequest.Method = .put
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
