//
//  QueryTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation
import HTTPTypes

@Suite("Query Tests")
struct QueryTests {
    let baseURL = "https://api.example.com"

    // MARK: - Single Query

    @Test func singleQuery() throws {
        let request = Get<Data>("users")
            .query(name: "page", value: "1")

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("page=1"))
    }

    // MARK: - Query Builder

    @Test func queriesBuilder() throws {
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                Query(name: "limit", value: "20")
            }

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("page=1"))
        #expect(path.contains("limit=20"))
    }

    // MARK: - Conditional Queries

    @Test func conditionalQueries() throws {
        let includeSearch = true
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                if includeSearch {
                    Query(name: "search", value: "john")
                }
            }

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("page=1"))
        #expect(path.contains("search=john"))
    }

    @Test func conditionalQueriesFalse() throws {
        let includeSearch = false
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                if includeSearch {
                    Query(name: "search", value: "john")
                }
            }

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("page=1"))
        #expect(!path.contains("search"))
    }

    // MARK: - Nil Value

    @Test func queryWithNilValue() throws {
        let request = Get<Data>("users")
            .query(name: "filter", value: nil)

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("filter"))
    }

    // MARK: - Special Characters

    @Test func queryWithSpecialCharacters() throws {
        let request = Get<Data>("search")
            .query(name: "q", value: "hello world")

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        // URL encoding should handle spaces
        #expect(path.contains("q=hello%20world"))
    }

    // MARK: - Multiple Queries Chained

    @Test func chainedQueries() throws {
        let request = Get<Data>("users")
            .query(name: "page", value: "1")
            .query(name: "limit", value: "10")

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("page=1"))
        #expect(path.contains("limit=10"))
    }

    // MARK: - Query with name and value shorthand

    @Test func queryShorthand() throws {
        let request = Get<Data>("users")
            .query(name: "page", value: "1")

        let httpRequest = try request.httpRequest(baseURL: baseURL)
        let path = try #require(httpRequest.path)

        #expect(path.contains("page=1"))
    }
}
