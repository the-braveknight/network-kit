//
//  Get.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A GET request for retrieving resources from the server.
///
/// ## Usage
///
/// ```swift
/// let request = Get<User>("users", "42")
///     .header(.authorization, "Bearer token")
///     .queries {
///         Query(name: "include", value: "profile")
///     }
///
/// let response = try await service.load(request)
/// ```
public struct Get<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPRequest.Method = .get
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
