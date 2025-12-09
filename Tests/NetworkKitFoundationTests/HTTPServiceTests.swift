//
//  HTTPServiceTests.swift
//  NetworkKitFoundation
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
import Foundation
@testable import NetworkKit
@testable import NetworkKitFoundation

@Suite("HTTPService Tests")
struct HTTPServiceTests {

    // MARK: - Service Configuration

    @Test func defaultSession() {
        struct TestService: HTTPService {
            let baseURL = URL(string: "https://api.example.com")!
        }

        let service = TestService()
        #expect(service.session === URLSession.shared)
    }

    @Test func customSession() {
        struct TestService: HTTPService {
            let baseURL = URL(string: "https://api.example.com")!
            let session: URLSession
        }

        let customSession = URLSession(configuration: .ephemeral)
        let service = TestService(session: customSession)
        #expect(service.session === customSession)
    }

    @Test func defaultDecoder() {
        struct TestService: HTTPService {
            let baseURL = URL(string: "https://api.example.com")!
        }

        let service = TestService()
        // Just verify it returns a JSONDecoder
        _ = service.decoder
    }

    @Test func customDecoder() throws {
        struct TestService: HTTPService {
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

    @Test func baseURLAsURL() {
        struct TestService: HTTPService {
            let baseURL = URL(string: "https://api.example.com/v1")!
        }

        let service = TestService()
        #expect(service.baseURL.absoluteString == "https://api.example.com/v1")
    }
}
