//
//  EndpointTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation
import HTTPTypes

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
            .header(.accept, "application/json")
    }
}

struct CreateUser: Endpoint {
    let input: CreateUserInput

    var request: some Request<User> {
        Post<User>("users")
            .header(.authorization, "Bearer test-token")
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
    let baseURL = "https://api.example.com"

    @Test func getEndpoint() throws {
        let endpoint = GetUser(userID: "42")
        let httpRequest = try endpoint.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .get)
        #expect(httpRequest.path == "/users/42")
        #expect(httpRequest.headerFields[.accept] == "application/json")
    }

    @Test func postEndpoint() throws {
        let input = CreateUserInput(name: "John", email: "john@example.com")
        let endpoint = CreateUser(input: input)
        let httpRequest = try endpoint.httpRequest(baseURL: baseURL)

        #expect(httpRequest.method == .post)
        #expect(httpRequest.path == "/users")
        #expect(httpRequest.headerFields[.authorization] == "Bearer test-token")
        #expect(httpRequest.headerFields[.contentType] == "application/json")

        let body = try #require(endpoint.request.components.body)
        let json = try #require(String(data: body, encoding: .utf8))

        #expect(json.contains("John"))
        #expect(json.contains("john@example.com"))
    }

    @Test func endpointWithQueries() throws {
        let endpoint = SearchUsers(query: "john", page: 2)
        let httpRequest = try endpoint.httpRequest(baseURL: baseURL)

        let path = try #require(httpRequest.path)

        #expect(path.contains("q=john"))
        #expect(path.contains("page=2"))
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

// MARK: - Request URL Tests

@Suite("Request URL Tests")
struct RequestURLTests {
    let baseURL = "https://api.example.com"

    @Test func requestBuildsCorrectURL() throws {
        let request = Get<Data>("users", "42")
        let httpRequest = try request.httpRequest(baseURL: baseURL)

        #expect(httpRequest.scheme == "https")
        #expect(httpRequest.authority == "api.example.com")
        #expect(httpRequest.path == "/users/42")
    }

    @Test func requestWithBaseURLPath() throws {
        let baseWithPath = "https://api.example.com/v1"
        let request = Get<Data>("users", "42")
        let httpRequest = try request.httpRequest(baseURL: baseWithPath)

        #expect(httpRequest.path == "/v1/users/42")
    }
}
