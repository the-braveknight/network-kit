//
//  Request+Encoder.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/10/25.
//

extension Request {
    /// Sets a custom encoder for this request.
    ///
    /// Use this to override the service's default encoder for a specific request.
    ///
    /// ```swift
    /// let customEncoder = JSONEncoder()
    /// customEncoder.dateEncodingStrategy = .iso8601
    ///
    /// Post("/api/v1/events")
    ///     .body(event)
    ///     .encoder(customEncoder)
    /// ```
    public func encoder(_ encoder: some RequestEncoder) -> Self {
        var copy = self
        copy.components.encoder = encoder
        return copy
    }
}
