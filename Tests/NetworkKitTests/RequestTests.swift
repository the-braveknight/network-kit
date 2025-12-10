//
//  RequestTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/9/25.
//

import Testing
@testable import NetworkKit
import Foundation
import HTTPTypes

@Suite("Request Tests")
struct RequestTests {

    // MARK: - HTTP Methods

    @Test func getRequest() {
        let request = Get<Data>("users", "42")
        #expect(request.method == .get)
        #expect(request.pathComponents == ["users", "42"])
    }

    @Test func postRequest() {
        let request = Post<Data>("users")
        #expect(request.method == .post)
        #expect(request.pathComponents == ["users"])
    }

    @Test func putRequest() {
        let request = Put<Data>("users", "42")
        #expect(request.method == .put)
        #expect(request.pathComponents == ["users", "42"])
    }

    @Test func patchRequest() {
        let request = Patch<Data>("users", "42")
        #expect(request.method == .patch)
        #expect(request.pathComponents == ["users", "42"])
    }

    @Test func deleteRequest() {
        let request = Delete<Data>("users", "42")
        #expect(request.method == .delete)
        #expect(request.pathComponents == ["users", "42"])
    }

    @Test func headRequest() {
        let request = Head<Data>("users")
        #expect(request.method == .head)
        #expect(request.pathComponents == ["users"])
    }

    @Test func optionsRequest() {
        let request = Options<Data>("users")
        #expect(request.method == .options)
        #expect(request.pathComponents == ["users"])
    }

    // MARK: - Path Components

    @Test func emptyPath() {
        let request = Get<Data>()
        #expect(request.pathComponents.isEmpty)
    }

    @Test func multiplePaths() {
        let request = Get<Data>("api", "v2", "users", "profile")
        #expect(request.pathComponents == ["api", "v2", "users", "profile"])
    }

    // MARK: - Request ID

    @Test func uniqueRequestID() {
        let request1 = Get<Data>("users")
        let request2 = Get<Data>("users")

        #expect(request1.id != request2.id)
    }
}
