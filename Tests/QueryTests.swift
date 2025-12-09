//
//  QueryTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation

@Suite("Query Tests")
struct QueryTests {
    let baseURL = URL(string: "https://api.example.com")!

    // MARK: - Single Query

    @Test func singleQuery() throws {
        let request = Get<Data>("users")
            .query(Query(name: "page", value: "1"))

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)

        #expect(url.query?.contains("page=1") == true)
    }

    // MARK: - Query Builder

    @Test func queriesBuilder() throws {
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                Query(name: "limit", value: "20")
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)
        let query = try #require(url.query)

        #expect(query.contains("page=1"))
        #expect(query.contains("limit=20"))
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

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)
        let query = try #require(url.query)

        #expect(query.contains("page=1"))
        #expect(query.contains("search=john"))
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

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)
        let query = try #require(url.query)

        #expect(query.contains("page=1"))
        #expect(!query.contains("search"))
    }

    // MARK: - Nil Value

    @Test func queryWithNilValue() throws {
        let request = Get<Data>("users")
            .query(Query(name: "filter", value: nil))

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)

        #expect(url.query?.contains("filter") == true)
    }

    // MARK: - Special Characters

    @Test func queryWithSpecialCharacters() throws {
        let request = Get<Data>("search")
            .query(Query(name: "q", value: "hello world"))

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)

        // URL encoding should handle spaces
        #expect(url.absoluteString.contains("q=hello%20world") || url.absoluteString.contains("q=hello+world"))
    }

    // MARK: - Multiple Queries Chained

    @Test func chainedQueries() throws {
        let request = Get<Data>("users")
            .query(Query(name: "page", value: "1"))
            .query(Query(name: "limit", value: "10"))

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let url = try #require(urlRequest.url)
        let query = try #require(url.query)

        #expect(query.contains("page=1"))
        #expect(query.contains("limit=10"))
    }

    // MARK: - Query Type

    @Test func queryURLQueryItem() {
        let query = Query(name: "key", value: "value")
        let urlQueryItem = query.urlQueryItem

        #expect(urlQueryItem.name == "key")
        #expect(urlQueryItem.value == "value")
    }
}
