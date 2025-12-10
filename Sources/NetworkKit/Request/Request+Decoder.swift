//
//  Request+Decoder.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/10/25.
//

extension Request {
    /// Sets a custom decoder for this request.
    ///
    /// Use this to override the service's default decoder for a specific request.
    ///
    /// ```swift
    /// let customDecoder = JSONDecoder()
    /// customDecoder.dateDecodingStrategy = .iso8601
    ///
    /// Get("/api/v1/events")
    ///     .decoder(customDecoder)
    /// ```
    public func decoder(_ decoder: some ResponseDecoder) -> Self {
        var copy = self
        copy.components.decoder = decoder
        return copy
    }
}
