//
//  APIService.swift
//  NetworkingIdeas
//
//  Created by Zaid Rahhawi on 4/8/24.
//

import SwiftUI
import NetworkKit
import NetworkKitFoundation

struct HTTPGoRESTService: HTTPURLSessionService, GoRESTService {
    let baseURL = URL(string: "https://gorest.co.in/public/v2")!

    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            guard let date = iso8601Formatter.date(from: dateString) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Invalid date format: \(dateString)"
                    )
                )
            }
            return date
        }
        return decoder
    }

    func loadPosts(page: Int) async throws -> PaginatedResponse<Post> {
        let endpoint = GetPosts(page: page)
        let response = try await load(endpoint)
        let pagination = try PaginationMetadata(from: response.headerFields)
        return try PaginatedResponse(items: response.body, pagination: pagination)
    }

    func loadTodos(page: Int) async throws -> PaginatedResponse<Todo> {
        let endpoint = GetTodos(page: page)
        let response = try await load(endpoint)
        let pagination = try PaginationMetadata(from: response.headerFields)
        return try PaginatedResponse(items: response.body, pagination: pagination)
    }

    func loadUsers(page: Int) async throws -> PaginatedResponse<User> {
        let endpoint = GetUsers(page: page)
        let response = try await load(endpoint)
        let pagination = try PaginationMetadata(from: response.headerFields)
        return try PaginatedResponse(items: response.body, pagination: pagination)
    }
}
