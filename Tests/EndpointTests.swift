//
//  EndpointTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation

// MARK: - Mock Service

struct MockService: HTTPService {
    let baseURL = URL(string: "https://api.example.com")!
}

// MARK: - Test Types

struct User: Codable, Sendable {
    let id: Int
    let name: String
}

struct CreateUserInput: Encodable {
    let name: String
    let email: String
}

// MARK: - Test Endpoints

struct GetUser: Endpoint {
    let userID: String

    var request: some Request<User> {
        Get<User>("users", userID)
            .accept(.json)
    }
}

struct CreateUser: Endpoint {
    let input: CreateUserInput

    var request: some Request<User> {
        Post<User>("users")
            .authorization(.bearer(token: "test-token"))
            .body(input)
    }
}

struct SearchUsers: Endpoint {
    let query: String
    let page: Int

    var request: some Request<[User]> {
        Get<[User]>("users")
            .queries {
                Query(name: "q", value: query)
                Query(name: "page", value: String(page))
            }
    }
}

// MARK: - Tests

@Suite("Endpoint Tests")
struct EndpointTests {
    let baseURL = URL(string: "https://api.example.com")!

    @Test func getEndpoint() throws {
        let endpoint = GetUser(userID: "42")
        let urlRequest = try endpoint.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.url?.path == "/users/42")
        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func postEndpoint() throws {
        let input = CreateUserInput(name: "John", email: "john@example.com")
        let endpoint = CreateUser(input: input)
        let urlRequest = try endpoint.urlRequest(baseURL: baseURL)

        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.url?.path == "/users")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let body = try #require(urlRequest.httpBody)
        let json = try #require(String(data: body, encoding: .utf8))

        #expect(json.contains("John"))
        #expect(json.contains("john@example.com"))
    }

    @Test func endpointWithQueries() throws {
        let endpoint = SearchUsers(query: "john", page: 2)
        let urlRequest = try endpoint.urlRequest(baseURL: baseURL)

        let url = try #require(urlRequest.url)
        let query = try #require(url.query)

        #expect(query.contains("q=john"))
        #expect(query.contains("page=2"))
    }

    @Test func endpointResponseType() {
        // Verify type inference works correctly
        let getUserEndpoint = GetUser(userID: "1")
        let searchEndpoint = SearchUsers(query: "test", page: 1)

        // These assertions verify the Response associated type is correctly inferred
        #expect(type(of: getUserEndpoint).Response.self == User.self)
        #expect(type(of: searchEndpoint).Response.self == [User].self)
    }
}

// MARK: - HTTPService Tests

@Suite("HTTPService Tests")
struct HTTPServiceTests {
    let baseURL = URL(string: "https://api.example.com")!

    @Test func serviceHasDefaultSession() {
        let service = MockService()
        #expect(service.session === URLSession.shared)
    }

    @Test func serviceHasDefaultDecoder() {
        let service = MockService()
        // Just verify we can access the decoder
        _ = service.decoder
    }

    @Test func requestBuildsCorrectURL() throws {
        let request = Get<Data>("users", "42")
        let urlRequest = try request.urlRequest(baseURL: baseURL)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users/42")
    }
}
