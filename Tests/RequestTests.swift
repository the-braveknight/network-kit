//
//  RequestTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation

@Suite("Request Tests")
struct RequestTests {
    let baseURL = URL(string: "https://api.example.com")!

    // MARK: - HTTP Methods

    @Test func getRequest() throws {
        let request = Get<Data>("users", "42")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.url?.path == "/users/42")
    }

    @Test func postRequest() throws {
        let request = Post<Data>("users")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.url?.path == "/users")
    }

    @Test func putRequest() throws {
        let request = Put<Data>("users", "42")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "PUT")
    }

    @Test func patchRequest() throws {
        let request = Patch<Data>("users", "42")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "PATCH")
    }

    @Test func deleteRequest() throws {
        let request = Delete<Data>("users", "42")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "DELETE")
    }

    @Test func headRequest() throws {
        let request = Head<Data>("users")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "HEAD")
    }

    @Test func optionsRequest() throws {
        let request = Options<Data>("users")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "OPTIONS")
    }

    // MARK: - Path Components

    @Test func emptyPath() throws {
        let request = Get<Data>()
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.url?.path == "/")
    }

    @Test func multiplePaths() throws {
        let request = Get<Data>("api", "v2", "users", "profile")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.url?.path == "/api/v2/users/profile")
    }

    @Test func baseURLWithPath() throws {
        let baseWithPath = URL(string: "https://api.example.com/v1")!
        let request = Get<Data>("users")
        let urlRequest = try request.urlRequest(baseURL: baseWithPath)

        #expect(urlRequest.url?.path == "/v1/users")
    }

    // MARK: - Request Configuration

    @Test func timeout() throws {
        let request = Get<Data>("users").timeout(30)
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.timeoutInterval == 30)
    }

    @Test func cachePolicy() throws {
        let request = Get<Data>("users").cachePolicy(.reloadIgnoringLocalCacheData)
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.cachePolicy == .reloadIgnoringLocalCacheData)
    }

    @Test func cellularAccess() throws {
        let request = Get<Data>("users").allowsCellularAccess(false)
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.allowsCellularAccess == false)
    }

    // MARK: - Body

    @Test func rawDataBody() throws {
        let bodyData = Data("test body".utf8)
        let request = Post<Data>("users").body(bodyData)
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpBody == bodyData)
    }

    @Test func encodableBody() throws {
        struct Input: Encodable {
            let name: String
        }

        let request = Post<Data>("users").body(Input(name: "John"))
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        let body = try #require(urlRequest.httpBody)
        let json = try #require(String(data: body, encoding: .utf8))

        #expect(json.contains("John"))
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
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

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let body = try #require(urlRequest.httpBody)
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
            .header(ContentType(.json))
            .body(Data("{\"name\":\"John\"}".utf8))

        let curl = try request.cURLDescription(baseURL: baseURL)

        #expect(curl.contains("curl"))
        #expect(curl.contains("-X POST"))
        #expect(curl.contains("Content-Type: application/json"))
        #expect(curl.contains("https://api.example.com/users"))
    }
}
