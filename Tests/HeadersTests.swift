//
//  HeadersTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation

@Suite("Headers Tests")
struct HeadersTests {
    let baseURL = URL(string: "https://api.example.com")!

    // MARK: - Headers Builder

    @Test func headersBuilder() throws {
        let request = Get<Data>("users")
            .headers {
                Accept(.json)
                ContentType(.json)
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func singleHeader() throws {
        let request = Get<Data>("users")
            .header(Accept(.json))

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    // MARK: - Authorization

    @Test func bearerAuthorization() throws {
        let request = Get<Data>("users")
            .authorization(.bearer(token: "my-token"))

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer my-token")
    }

    @Test func basicAuthorization() throws {
        let request = Get<Data>("users")
            .authorization(.basic(username: "user", password: "pass"))

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let authHeader = try #require(urlRequest.value(forHTTPHeaderField: "Authorization"))

        #expect(authHeader.hasPrefix("Basic "))

        // Verify base64 encoding
        let base64Part = String(authHeader.dropFirst("Basic ".count))
        let decoded = try #require(Data(base64Encoded: base64Part))
        let credentials = try #require(String(data: decoded, encoding: .utf8))

        #expect(credentials == "user:pass")
    }

    @Test func authorizationWithHeadersBuilder() throws {
        let request = Get<Data>("users")
            .headers {
                Authorization(.bearer(token: "token123"))
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
    }

    // MARK: - Content Type

    @Test func contentTypeModifier() throws {
        let request = Post<Data>("users")
            .contentType(.json)

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func contentTypeVariants() throws {
        let requests = [
            (Post<Data>("a").contentType(.json), "application/json"),
            (Post<Data>("b").contentType(.xml), "application/xml"),
            (Post<Data>("c").contentType(.text), "text/plain"),
            (Post<Data>("d").contentType(.html), "text/html"),
        ]

        for (request, expected) in requests {
            let urlRequest = try request.urlRequest(baseURL: baseURL)
            #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == expected)
        }
    }

    // MARK: - Accept

    @Test func acceptModifier() throws {
        let request = Get<Data>("users")
            .accept(.json)

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    // MARK: - User Agent

    @Test func userAgentModifier() throws {
        let request = Get<Data>("users")
            .userAgent("MyApp/1.0")

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "User-Agent") == "MyApp/1.0")
    }

    // MARK: - Multiple Headers

    @Test func multipleHeaders() throws {
        let request = Get<Data>("users")
            .authorization(.bearer(token: "token"))
            .accept(.json)
            .contentType(.json)
            .userAgent("MyApp/1.0")

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token")
        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "User-Agent") == "MyApp/1.0")
    }

    // MARK: - Conditional Headers

    @Test func conditionalHeaders() throws {
        let includeAuth = true
        let request = Get<Data>("users")
            .headers {
                Accept(.json)
                if includeAuth {
                    Authorization(.bearer(token: "token"))
                }
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }

    @Test func conditionalHeadersFalse() throws {
        let includeAuth = false
        let request = Get<Data>("users")
            .headers {
                Accept(.json)
                if includeAuth {
                    Authorization(.bearer(token: "token"))
                }
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == nil)
    }
}

// MARK: - MIME Type Tests

@Suite("MIMEType Tests")
struct MIMETypeTests {
    @Test func predefinedTypes() {
        #expect(MIMEType.json.value == "application/json")
        #expect(MIMEType.xml.value == "application/xml")
        #expect(MIMEType.text.value == "text/plain")
        #expect(MIMEType.html.value == "text/html")
        #expect(MIMEType.png.value == "image/png")
        #expect(MIMEType.jpeg.value == "image/jpeg")
        #expect(MIMEType.pdf.value == "application/pdf")
    }

    @Test func customMIMEType() {
        let mimeType = MIMEType(type: .application, subType: .json)
        #expect(mimeType.value == "application/json")
    }

    @Test func mimeTypeWithParameters() {
        let mimeType = MIMEType(
            type: .multipart,
            subType: .formData,
            parameters: .boundary("abc123")
        )

        #expect(mimeType.value.contains("multipart/form-data"))
        #expect(mimeType.value.contains("boundary"))
    }

    @Test func stringLiteralMIMEType() {
        let mimeType: MIMEType = "application/json"
        #expect(mimeType.type.value == "application")
        #expect(mimeType.subType.value == "json")
    }
}
