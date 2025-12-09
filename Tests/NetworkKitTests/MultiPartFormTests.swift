//
//  MultiPartFormTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 3/6/25.
//

import Testing
@testable import NetworkKit
import Foundation
import HTTPTypes

// MARK: - Text Field Tests

@Suite("Text Field Tests")
struct TextFieldTests {
    @Test func textFieldBody() {
        let text = Text("Hello, World!")
        #expect(text.body == Data("Hello, World!".utf8))
    }

    @Test func textFieldValue() {
        let text = Text("Test Value")
        #expect(text.value == "Test Value")
    }

    @Test func emptyTextField() {
        let text = Text("")
        #expect(text.body.isEmpty)
    }

    @Test func textFieldWithSpecialCharacters() {
        let text = Text("Hello\nWorld\t!")
        let bodyString = String(data: text.body, encoding: .utf8)
        #expect(bodyString == "Hello\nWorld\t!")
    }

    @Test func textFieldWithUnicode() {
        let text = Text("Hello 世界 🌍")
        let bodyString = String(data: text.body, encoding: .utf8)
        #expect(bodyString == "Hello 世界 🌍")
    }
}

// MARK: - File Field Tests

@Suite("File Field Tests")
struct FileFieldTests {
    @Test func fileFieldFromData() {
        let data = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes
        let file = File(data: data)
        #expect(file.body == data)
    }

    @Test func emptyFileField() {
        let file = File(data: Data())
        #expect(file.body.isEmpty)
    }

    @Test func binaryFileData() {
        let binaryData = Data((0..<256).map { UInt8($0) })
        let file = File(data: binaryData)
        #expect(file.body.count == 256)
    }
}

// MARK: - Content Disposition Tests

@Suite("Content Disposition Tests")
struct ContentDispositionTests {
    @Test func formDataDisposition() {
        let text = Text("test")
            .contentDisposition(name: "field")

        let dispositionHeader = text.headers[.contentDisposition]
        #expect(dispositionHeader?.contains("form-data") == true)
        #expect(dispositionHeader?.contains("name=\"field\"") == true)
    }

    @Test func dispositionWithFilename() {
        let file = File(data: Data())
            .contentDisposition(name: "file", filename: "image.png")

        let dispositionHeader = file.headers[.contentDisposition]
        #expect(dispositionHeader?.contains("form-data") == true)
        #expect(dispositionHeader?.contains("name=\"file\"") == true)
        #expect(dispositionHeader?.contains("filename=\"image.png\"") == true)
    }
}

// MARK: - MultiPartForm Structure Tests

@Suite("MultiPartForm Structure Tests")
struct MultiPartFormStructureTests {
    @Test func formBoundary() {
        let form = MultiPartForm(boundary: "TestBoundary", fields: [])
        #expect(form.boundary == "TestBoundary")
    }

    @Test func formContentType() {
        let form = MultiPartForm(boundary: "MyBoundary", fields: [])
        let contentType = form.contentTypeValue

        #expect(contentType.contains("multipart/form-data"))
        #expect(contentType.contains("boundary"))
        #expect(contentType.contains("MyBoundary"))
    }

    @Test func emptyFormData() {
        let form = MultiPartForm(boundary: "Boundary", fields: [])
        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("--Boundary--"))
    }

    @Test func singleTextField() {
        let form = MultiPartForm(boundary: "Boundary") {
            Text("Hello")
                .contentDisposition(name: "message")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("--Boundary"))
        #expect(dataString.contains("Content-Disposition: form-data; name=\"message\""))
        #expect(dataString.contains("Hello"))
        #expect(dataString.contains("--Boundary--"))
    }

    @Test func multipleFields() {
        let form = MultiPartForm(boundary: "Boundary") {
            Text("Value1")
                .contentDisposition(name: "field1")
            Text("Value2")
                .contentDisposition(name: "field2")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("name=\"field1\""))
        #expect(dataString.contains("Value1"))
        #expect(dataString.contains("name=\"field2\""))
        #expect(dataString.contains("Value2"))
    }

    @Test func fieldWithContentType() {
        let form = MultiPartForm(boundary: "Boundary") {
            Text("JSON data")
                .contentDisposition(name: "data")
                .contentType("application/json")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("Content-Type: application/json"))
    }

    @Test func fileFieldWithHeaders() {
        let imageData = Data("FakeImageData".utf8)
        let form = MultiPartForm(boundary: "Boundary") {
            File(data: imageData)
                .contentDisposition(name: "avatar", filename: "profile.jpg")
                .contentType("image/jpeg")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("Content-Disposition: form-data; name=\"avatar\"; filename=\"profile.jpg\""))
        #expect(dataString.contains("Content-Type: image/jpeg"))
        #expect(dataString.contains("FakeImageData"))
    }

    @Test func headerOrderingContentDispositionFirst() {
        let form = MultiPartForm(boundary: "Boundary") {
            Text("Test")
                .contentType("text/plain")
                .contentDisposition(name: "field")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        // Content-Disposition should come before Content-Type
        let dispositionIndex = dataString.range(of: "Content-Disposition")!.lowerBound
        let typeIndex = dataString.range(of: "Content-Type")!.lowerBound

        #expect(dispositionIndex < typeIndex)
    }
}

// MARK: - Request Integration Tests

@Suite("MultiPartForm Request Integration Tests")
struct MultiPartFormRequestTests {
    let baseURL = "https://api.example.com"

    @Test func requestWithMultiPartForm() throws {
        let request = Post<Data>("upload")
            .multiPartForm(boundary: "TestBoundary") {
                Text("Hello")
                    .contentDisposition(name: "message")
            }

        let httpRequest = try request.httpRequest(baseURL: baseURL)

        let contentType = try #require(httpRequest.headerFields[.contentType])
        #expect(contentType.contains("multipart/form-data"))
        #expect(contentType.contains("boundary"))

        let body = try #require(request.components.body)
        let bodyString = try #require(String(data: body, encoding: .utf8))
        #expect(bodyString.contains("Hello"))
    }

    @Test func complexFormUpload() throws {
        let request = Post<Data>("upload")
            .multiPartForm(boundary: "ComplexBoundary") {
                Text("John Doe")
                    .contentDisposition(name: "fullName")
                    .contentType("text/plain")

                Text("john@example.com")
                    .contentDisposition(name: "email")

                File(data: Data("ProfileImageData".utf8))
                    .contentDisposition(name: "avatar", filename: "avatar.png")
                    .contentType("image/png")

                File(data: Data("ResumeData".utf8))
                    .contentDisposition(name: "resume", filename: "resume.pdf")
                    .contentType("application/pdf")
            }

        let body = try #require(request.components.body)
        let bodyString = try #require(String(data: body, encoding: .utf8))

        #expect(bodyString.contains("John Doe"))
        #expect(bodyString.contains("john@example.com"))
        #expect(bodyString.contains("ProfileImageData"))
        #expect(bodyString.contains("ResumeData"))
        #expect(bodyString.contains("avatar.png"))
        #expect(bodyString.contains("resume.pdf"))
    }

    @Test func formWithConditionalFields() throws {
        let includeOptional = true

        let request = Post<Data>("upload")
            .multiPartForm(boundary: "Boundary") {
                Text("Required")
                    .contentDisposition(name: "required")

                if includeOptional {
                    Text("Optional")
                        .contentDisposition(name: "optional")
                }
            }

        let body = try #require(request.components.body)
        let bodyString = try #require(String(data: body, encoding: .utf8))

        #expect(bodyString.contains("Required"))
        #expect(bodyString.contains("Optional"))
    }

    @Test func formWithConditionalFieldsFalse() throws {
        let includeOptional = false

        let request = Post<Data>("upload")
            .multiPartForm(boundary: "Boundary") {
                Text("Required")
                    .contentDisposition(name: "required")

                if includeOptional {
                    Text("Optional")
                        .contentDisposition(name: "optional")
                }
            }

        let body = try #require(request.components.body)
        let bodyString = try #require(String(data: body, encoding: .utf8))

        #expect(bodyString.contains("Required"))
        #expect(!bodyString.contains("Optional"))
    }
}

// MARK: - Boundary Format Tests

@Suite("Boundary Format Tests")
struct BoundaryFormatTests {
    @Test func boundaryInData() {
        let form = MultiPartForm(boundary: "ABC123") {
            Text("Test")
                .contentDisposition(name: "field")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        // Each field should be preceded by --boundary
        #expect(dataString.contains("--ABC123\r\n"))

        // Form should end with --boundary--
        #expect(dataString.contains("--ABC123--"))
    }

    @Test func multipleFieldBoundaries() {
        let form = MultiPartForm(boundary: "SEP") {
            Text("A").contentDisposition(name: "a")
            Text("B").contentDisposition(name: "b")
            Text("C").contentDisposition(name: "c")
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        // Count boundary occurrences (3 fields + 1 closing = should have 3 "--SEP\r\n" and 1 "--SEP--")
        let boundaryCount = dataString.components(separatedBy: "--SEP\r\n").count - 1
        #expect(boundaryCount == 3)

        #expect(dataString.hasSuffix("--SEP--\r\n"))
    }
}
