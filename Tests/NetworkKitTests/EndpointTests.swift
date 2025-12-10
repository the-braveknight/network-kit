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

struct CreateUserInput: Encodable, Sendable {
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

    @Test func getEndpoint() {
        let endpoint = GetUser(userID: "42")

        #expect(endpoint.request.method == .get)
        #expect(endpoint.request.pathComponents == ["users", "42"])
        #expect(endpoint.request.components.headerFields[.accept] == "application/json")
    }

    @Test func postEndpoint() throws {
        let input = CreateUserInput(name: "John", email: "john@example.com")
        let endpoint = CreateUser(input: input)

        #expect(endpoint.request.method == .post)
        #expect(endpoint.request.pathComponents == ["users"])
        #expect(endpoint.request.components.headerFields[.authorization] == "Bearer test-token")

        // Verify body is set
        let body = try #require(endpoint.request.components.body)
        let encoded = try body.encode(using: JSONEncoder())
        let json = try #require(String(data: encoded, encoding: .utf8))

        #expect(json.contains("John"))
        #expect(json.contains("john@example.com"))
    }

    @Test func endpointWithQueries() {
        let endpoint = SearchUsers(query: "john", page: 2)

        #expect(endpoint.request.components.queryItems.count == 2)
        #expect(endpoint.request.components.queryItems.contains { $0.name == "q" && $0.value == "john" })
        #expect(endpoint.request.components.queryItems.contains { $0.name == "page" && $0.value == "2" })
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
