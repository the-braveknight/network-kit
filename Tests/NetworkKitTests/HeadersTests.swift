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

    // MARK: - Single Header

    @Test func singleHeader() {
        let request = Get<Data>("users")
            .header(.accept, "application/json")

        #expect(request.components.headerFields[.accept] == "application/json")
    }

    // MARK: - Multiple Headers

    @Test func multipleHeaders() {
        let request = Get<Data>("users")
            .header(.authorization, "Bearer token")
            .header(.accept, "application/json")
            .header(.contentType, "application/json")
            .header(.userAgent, "MyApp/1.0")

        #expect(request.components.headerFields[.authorization] == "Bearer token")
        #expect(request.components.headerFields[.accept] == "application/json")
        #expect(request.components.headerFields[.contentType] == "application/json")
        #expect(request.components.headerFields[.userAgent] == "MyApp/1.0")
    }

    // MARK: - Authorization

    @Test func bearerAuthorization() {
        let request = Get<Data>("users")
            .header(.authorization, "Bearer my-token")

        #expect(request.components.headerFields[.authorization] == "Bearer my-token")
    }

    @Test func basicAuthorization() throws {
        let credentials = "user:pass".data(using: .utf8)!.base64EncodedString()
        let request = Get<Data>("users")
            .header(.authorization, "Basic \(credentials)")

        let authHeader = try #require(request.components.headerFields[.authorization])
        #expect(authHeader.hasPrefix("Basic "))

        // Verify base64 encoding
        let base64Part = String(authHeader.dropFirst("Basic ".count))
        let decoded = try #require(Data(base64Encoded: base64Part))
        let decodedCredentials = try #require(String(data: decoded, encoding: .utf8))

        #expect(decodedCredentials == "user:pass")
    }

    // MARK: - Content Type

    @Test func contentTypeHeader() {
        let request = Post<Data>("users")
            .header(.contentType, "application/json")

        #expect(request.components.headerFields[.contentType] == "application/json")
    }

    @Test func contentTypeVariants() {
        let jsonRequest = Post<Data>("a").header(.contentType, "application/json")
        let xmlRequest = Post<Data>("b").header(.contentType, "application/xml")
        let textRequest = Post<Data>("c").header(.contentType, "text/plain")
        let htmlRequest = Post<Data>("d").header(.contentType, "text/html")

        #expect(jsonRequest.components.headerFields[.contentType] == "application/json")
        #expect(xmlRequest.components.headerFields[.contentType] == "application/xml")
        #expect(textRequest.components.headerFields[.contentType] == "text/plain")
        #expect(htmlRequest.components.headerFields[.contentType] == "text/html")
    }

    // MARK: - Accept

    @Test func acceptHeader() {
        let request = Get<Data>("users")
            .header(.accept, "application/json")

        #expect(request.components.headerFields[.accept] == "application/json")
    }

    // MARK: - User Agent

    @Test func userAgentHeader() {
        let request = Get<Data>("users")
            .header(.userAgent, "MyApp/1.0")

        #expect(request.components.headerFields[.userAgent] == "MyApp/1.0")
    }

    // MARK: - Header Overwrite

    @Test func headerOverwrite() {
        let request = Get<Data>("users")
            .header(.accept, "text/plain")
            .header(.accept, "application/json")

        #expect(request.components.headerFields[.accept] == "application/json")
    }

    // MARK: - Custom Headers

    @Test func customHeader() {
        let request = Get<Data>("users")
            .header(.init("X-Custom-Header")!, "custom-value")

        #expect(request.components.headerFields[.init("X-Custom-Header")!] == "custom-value")
    }

    // MARK: - Headers Builder

    @Test func headersBuilder() {
        let request = Get<Data>("users")
            .headers {
                Authorization(.bearer(token: "my-token"))
                Accept(.json)
                ContentType(.json)
                UserAgent("MyApp/1.0")
            }

        #expect(request.components.headerFields[.authorization] == "Bearer my-token")
        #expect(request.components.headerFields[.accept] == "application/json")
        #expect(request.components.headerFields[.contentType] == "application/json")
        #expect(request.components.headerFields[.userAgent] == "MyApp/1.0")
    }

    @Test func headersBuilderWithConditional() {
        let includeAuth = true
        let request = Get<Data>("users")
            .headers {
                Accept(.json)
                if includeAuth {
                    Authorization(.bearer(token: "my-token"))
                }
            }

        #expect(request.components.headerFields[.accept] == "application/json")
        #expect(request.components.headerFields[.authorization] == "Bearer my-token")
    }

    @Test func headersBuilderWithConditionalFalse() {
        let includeAuth = false
        let request = Get<Data>("users")
            .headers {
                Accept(.json)
                if includeAuth {
                    Authorization(.bearer(token: "my-token"))
                }
            }

        #expect(request.components.headerFields[.accept] == "application/json")
        #expect(request.components.headerFields[.authorization] == nil)
    }
}
