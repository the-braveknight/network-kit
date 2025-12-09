//
//  Delete.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A DELETE request for removing resources from the server.
///
/// ## Usage
///
/// ```swift
/// let request = Delete<Data>("users", "42")
///     .header(.authorization, "Bearer token")
///
/// let response = try await service.load(request)
/// ```
public struct Delete<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPRequest.Method = .delete
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
