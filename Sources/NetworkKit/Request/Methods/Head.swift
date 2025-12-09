//
//  Head.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A HEAD request for retrieving headers without the response body.
///
/// HEAD is identical to GET, but the server does not return a message body.
/// This is useful for checking resource metadata, such as content length or last modified date.
///
/// ## Usage
///
/// ```swift
/// let request = Head<Data>("files", "document.pdf")
///     .header(.authorization, "Bearer token")
///
/// let response = try await service.load(request)
/// print("Content-Length: \(response.headerFields[.contentLength])")
/// ```
public struct Head<ResponseBody: Decodable & Sendable>: Request {
    public let id = UUID()
    public let method: HTTPRequest.Method = .head
    public let pathComponents: [String]
    public var components: RequestComponents

    public init(_ pathComponents: String...) {
        self.pathComponents = pathComponents
        self.components = RequestComponents()
    }
}
