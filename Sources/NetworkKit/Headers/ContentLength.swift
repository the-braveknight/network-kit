//
//  ContentLength.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A Content-Length header.
public struct ContentLength: HTTPHeader {
    public let name: HTTPField.Name = .contentLength
    public let value: String

    public init(_ length: Int) {
        self.value = String(length)
    }
}
