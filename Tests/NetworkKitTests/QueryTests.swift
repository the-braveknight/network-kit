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

    // MARK: - Single Query

    @Test func singleQuery() {
        let request = Get<Data>("users")
            .query(name: "page", value: "1")

        #expect(request.components.queryItems.count == 1)
        #expect(request.components.queryItems[0].name == "page")
        #expect(request.components.queryItems[0].value == "1")
    }

    // MARK: - Query Builder

    @Test func queriesBuilder() {
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                Query(name: "limit", value: "20")
            }

        #expect(request.components.queryItems.count == 2)
        #expect(request.components.queryItems[0].name == "page")
        #expect(request.components.queryItems[0].value == "1")
        #expect(request.components.queryItems[1].name == "limit")
        #expect(request.components.queryItems[1].value == "20")
    }

    // MARK: - Conditional Queries

    @Test func conditionalQueries() {
        let includeSearch = true
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                if includeSearch {
                    Query(name: "search", value: "john")
                }
            }

        #expect(request.components.queryItems.count == 2)
        #expect(request.components.queryItems.contains { $0.name == "search" && $0.value == "john" })
    }

    @Test func conditionalQueriesFalse() {
        let includeSearch = false
        let request = Get<Data>("users")
            .queries {
                Query(name: "page", value: "1")
                if includeSearch {
                    Query(name: "search", value: "john")
                }
            }

        #expect(request.components.queryItems.count == 1)
        #expect(!request.components.queryItems.contains { $0.name == "search" })
    }

    // MARK: - Nil Value

    @Test func queryWithNilValue() {
        let request = Get<Data>("users")
            .query(name: "filter", value: nil)

        #expect(request.components.queryItems.count == 1)
        #expect(request.components.queryItems[0].name == "filter")
        #expect(request.components.queryItems[0].value == nil)
    }

    // MARK: - Multiple Queries Chained

    @Test func chainedQueries() {
        let request = Get<Data>("users")
            .query(name: "page", value: "1")
            .query(name: "limit", value: "10")

        #expect(request.components.queryItems.count == 2)
        #expect(request.components.queryItems[0].name == "page")
        #expect(request.components.queryItems[1].name == "limit")
    }
}
