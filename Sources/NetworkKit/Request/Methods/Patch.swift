//
//  Patch.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A PATCH request for partially updating resources on the server.
///
/// ## Usage
///
/// ```swift
/// let request = Patch<User>("users", "42")
///     .header(.contentType, "application/json")
///     .body(PatchUserInput(name: "New Name"))
///
/// let response = try await service.load(request)
/// ```
public struct Patch<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPRequest.Method = .patch
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
