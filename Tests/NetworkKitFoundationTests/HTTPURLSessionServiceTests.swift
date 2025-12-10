//
//  HTTPURLSessionServiceTests.swift
//  NetworkKitFoundation
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
import Foundation
@testable import NetworkKit
@testable import NetworkKitFoundation

@Suite("HTTPURLSessionService Tests")
struct HTTPURLSessionServiceTests {
    
    // MARK: - Service Configuration
    
    @Test func serviceUsesCustomEncoder() throws {
        struct TestService: HTTPURLSessionService {
            let baseURL = URL(string: "https://api.example.com")!

            var encoder: JSONEncoder {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                return encoder
            }
        }

        struct CamelCaseModel: Encodable {
            let firstName: String
        }

        let service = TestService()
        let data = try service.encoder.encode(CamelCaseModel(firstName: "John"))
        let json = try #require(String(data: data, encoding: .utf8))
        #expect(json.contains("first_name"))
    }
    
    @Test func serviceUsesCustomDecoder() throws {
        struct TestService: HTTPURLSessionService {
            let baseURL = URL(string: "https://api.example.com")!

            var decoder: JSONDecoder {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }
        }

        struct SnakeCaseModel: Decodable {
            let firstName: String
        }

        let service = TestService()
        let json = #"{"first_name": "John"}"#.data(using: .utf8)!
        let model = try service.decoder.decode(SnakeCaseModel.self, from: json)
        #expect(model.firstName == "John")
    }
}

// MARK: - Request Body Encoding Tests

@Suite("Request Body Encoding Tests")
struct RequestBodyEncodingTests {
    @Test func encodableBodyUsesServiceEncoder() throws {
        struct Input: Encodable, Sendable {
            let firstName: String
        }
        
        let request = Post<Data>("users").body(Input(firstName: "John"))

        // Encode with snake_case encoder
        let snakeCaseEncoder = JSONEncoder()
        snakeCaseEncoder.keyEncodingStrategy = .convertToSnakeCase

        let body = try #require(request.components.body)
        let encoded = try body.encode(using: snakeCaseEncoder)
        let json = try #require(String(data: encoded, encoding: .utf8))

        #expect(json.contains("first_name"))
        #expect(!json.contains("firstName"))
    }

    @Test func encodableBodyWithDefaultEncoder() throws {
        struct Input: Encodable, Sendable {
            let firstName: String
        }

        let request = Post<Data>("users").body(Input(firstName: "John"))

        // Encode with default encoder (no key strategy)
        let body = try #require(request.components.body)
        let encoded = try body.encode(using: JSONEncoder())
        let json = try #require(String(data: encoded, encoding: .utf8))

        #expect(json.contains("firstName"))
        #expect(!json.contains("first_name"))
    }

    @Test func perRequestEncoderOverride() throws {
        struct Input: Encodable, Sendable {
            let firstName: String
        }

        let customEncoder = JSONEncoder()
        customEncoder.keyEncodingStrategy = .convertToSnakeCase

        let request = Post<Data>("users")
            .body(Input(firstName: "John"))
            .encoder(customEncoder)

        #expect(request.components.encoder != nil)
    }

    @Test func bodyBuilderSimple() throws {
        struct Input: Encodable, Sendable {
            let type: String
        }

        let request = Post<Data>("data")
            .body {
                Input(type: "test")
            }

        let body = try #require(request.components.body)
        let encoded = try body.encode(using: JSONEncoder())
        let json = try #require(String(data: encoded, encoding: .utf8))

        #expect(json.contains("test"))
    }
}
