//
//  HeadersTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation
import HTTPTypes

@Suite("Headers Tests")
struct HeadersTests {
    let baseURL = "https://api.example.com"

    // MARK: - Single Header

    @Test func singleHeader() throws {
        let request = Get<Data>("users")
            .header(.accept, "application/json")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.accept] == "application/json")
    }

    // MARK: - Multiple Headers

    @Test func multipleHeaders() throws {
        let request = Get<Data>("users")
            .header(.authorization, "Bearer token")
            .header(.accept, "application/json")
            .header(.contentType, "application/json")
            .header(.userAgent, "MyApp/1.0")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.authorization] == "Bearer token")
        #expect(httpRequest.headerFields[.accept] == "application/json")
        #expect(httpRequest.headerFields[.contentType] == "application/json")
        #expect(httpRequest.headerFields[.userAgent] == "MyApp/1.0")
    }

    // MARK: - Authorization

    @Test func bearerAuthorization() throws {
        let request = Get<Data>("users")
            .header(.authorization, "Bearer my-token")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.authorization] == "Bearer my-token")
    }

    @Test func basicAuthorization() throws {
        let credentials = "user:pass".data(using: .utf8)!.base64EncodedString()
        let request = Get<Data>("users")
            .header(.authorization, "Basic \(credentials)")

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let authHeader = try #require(httpRequest.headerFields[.authorization])

        #expect(authHeader.hasPrefix("Basic "))

        // Verify base64 encoding
        let base64Part = String(authHeader.dropFirst("Basic ".count))
        let decoded = try #require(Data(base64Encoded: base64Part))
        let decodedCredentials = try #require(String(data: decoded, encoding: .utf8))

        #expect(decodedCredentials == "user:pass")
    }

    // MARK: - Content Type

    @Test func contentTypeHeader() throws {
        let request = Post<Data>("users")
            .header(.contentType, "application/json")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.contentType] == "application/json")
    }

    @Test func contentTypeVariants() throws {
        let jsonRequest = Post<Data>("a").header(.contentType, "application/json")
        let xmlRequest = Post<Data>("b").header(.contentType, "application/xml")
        let textRequest = Post<Data>("c").header(.contentType, "text/plain")
        let htmlRequest = Post<Data>("d").header(.contentType, "text/html")

        #expect(try jsonRequest.httpRequest(baseURL: baseURL).headerFields[.contentType] == "application/json")
        #expect(try xmlRequest.httpRequest(baseURL: baseURL).headerFields[.contentType] == "application/xml")
        #expect(try textRequest.httpRequest(baseURL: baseURL).headerFields[.contentType] == "text/plain")
        #expect(try htmlRequest.httpRequest(baseURL: baseURL).headerFields[.contentType] == "text/html")
    }

    // MARK: - Accept

    @Test func acceptHeader() throws {
        let request = Get<Data>("users")
            .header(.accept, "application/json")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.accept] == "application/json")
    }

    // MARK: - User Agent

    @Test func userAgentHeader() throws {
        let request = Get<Data>("users")
            .header(.userAgent, "MyApp/1.0")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.userAgent] == "MyApp/1.0")
    }

    // MARK: - Header Overwrite

    @Test func headerOverwrite() throws {
        let request = Get<Data>("users")
            .header(.accept, "text/plain")
            .header(.accept, "application/json")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.accept] == "application/json")
    }

    // MARK: - Custom Headers

    @Test func customHeader() throws {
        let request = Get<Data>("users")
            .header(.init("X-Custom-Header")!, "custom-value")

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.headerFields[.init("X-Custom-Header")!] == "custom-value")
    }
}
