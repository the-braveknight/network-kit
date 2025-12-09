//
//  ContentLength.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 2/25/23.
//

import Foundation

public struct ContentLength: HTTPHeader {
    public let field: String = "Content-Length"
    public let contentLength: Int

    public var value: String {
        String(contentLength)
    }

    public init(_ contentLength: Int) {
        self.contentLength = contentLength
    }
}
