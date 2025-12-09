//
//  Patch.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// A PATCH request for partially updating resources on the server.
///
/// ## Usage
///
/// ```swift
/// let request = Patch<User>("users", "42")
///     .headers {
///         ContentType(.json)
///     }
///     .body(PatchUserInput(name: "New Name"))
///
/// let response = try await service.load(request)
/// ```
public struct Patch<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPMethod = .patch
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
