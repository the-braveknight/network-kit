//
//  Delete.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// A DELETE request for removing resources from the server.
///
/// ## Usage
///
/// ```swift
/// let request = Delete<EmptyResponse>("users", "42")
///     .headers {
///         Authorization(Bearer(token: "token"))
///     }
///
/// let response = try await service.load(request)
/// ```
public struct Delete<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPMethod = .delete
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
