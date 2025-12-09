//
//  RequestTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation
import HTTPTypes

@Suite("Request Tests")
struct RequestTests {
    let baseURL = "https://api.example.com"

    // MARK: - HTTP Methods

    @Test func getRequest() throws {
        let request = Get<Data>("users", "42")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .get)
        #expect(httpRequest.path == "/users/42")
    }

    @Test func postRequest() throws {
        let request = Post<Data>("users")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .post)
        #expect(httpRequest.path == "/users")
    }

    @Test func putRequest() throws {
        let request = Put<Data>("users", "42")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .put)
    }

    @Test func patchRequest() throws {
        let request = Patch<Data>("users", "42")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .patch)
    }

    @Test func deleteRequest() throws {
        let request = Delete<Data>("users", "42")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .delete)
    }

    @Test func headRequest() throws {
        let request = Head<Data>("users")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .head)
    }

    @Test func optionsRequest() throws {
        let request = Options<Data>("users")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .options)
    }

    // MARK: - Path Components

    @Test func emptyPath() throws {
        let request = Get<Data>()
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.path == "/")
    }

    @Test func multiplePaths() throws {
        let request = Get<Data>("api", "v2", "users", "profile")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.path == "/api/v2/users/profile")
    }

    @Test func baseURLWithPath() throws {
        let baseWithPath = "https://api.example.com/v1"
        let request = Get<Data>("users")
        let httpRequest = try request.httpRequest(baseURL: baseWithPath)

        #expect(httpRequest.path == "/v1/users")
    }

    // MARK: - Request Configuration

    @Test func timeout() throws {
        let request = Get<Data>("users").timeout(30)
        #expect(request.components.timeout == 30)
    }

    // MARK: - Body

    @Test func rawDataBody() throws {
        let bodyData = Data("test body".utf8)
        let request = Post<Data>("users").body(bodyData)

        #expect(request.components.body == bodyData)
    }

    @Test func encodableBody() throws {
        struct Input: Encodable {
            let name: String
        }

        let request = Post<Data>("users").body(Input(name: "John"))
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        let body = try #require(request.components.body)
        let json = try #require(String(data: body, encoding: .utf8))

        #expect(json.contains("John"))
        #expect(httpRequest.headerFields[.contentType] == "application/json")
    }

    @Test func bodyBuilder() throws {
        struct Input: Encodable {
            let value: Int
        }

        let useFirst = true
        let request = Post<Data>("data")
            .body {
                if useFirst {
                    Input(value: 1)
                } else {
                    Input(value: 2)
                }
            }

        let body = try #require(request.components.body)
        let json = try #require(String(data: body, encoding: .utf8))

        #expect(json.contains("1"))
    }

    // MARK: - Request ID

    @Test func uniqueRequestID() {
        let request1 = Get<Data>("users")
        let request2 = Get<Data>("users")

        #expect(request1.id != request2.id)
    }

    // MARK: - cURL Description

    @Test func curlDescription() throws {
        let request = Post<Data>("users")
            .header(.contentType, "application/json")
            .body(Data("{\"name\":\"John\"}".utf8))

        let curl = try request.cURLDescription(baseURL: baseURL)

        #expect(curl.contains("curl"))
        #expect(curl.contains("-X POST"))
        #expect(curl.contains("Content-Type: application/json"))
        #expect(curl.contains("https://api.example.com/users"))
    }
}
