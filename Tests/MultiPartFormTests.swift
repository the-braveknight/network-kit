//
//  MultiPartFormTests.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 3/6/25.
//

import Testing
@testable import NetworkKit
import Foundation

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
        let disposition = ContentDisposition(.formData)
        #expect(disposition.field == "Content-Disposition")
        #expect(disposition.value == "form-data")
    }

    @Test func inlineDisposition() {
        let disposition = ContentDisposition(.inline)
        #expect(disposition.value == "inline")
    }

    @Test func attachmentDisposition() {
        let disposition = ContentDisposition(.attachment)
        #expect(disposition.value == "attachment")
    }

    @Test func dispositionWithName() {
        let disposition = ContentDisposition(.formData, .name("fieldName"))
        #expect(disposition.value.contains("form-data"))
        #expect(disposition.value.contains("name=\"fieldName\""))
    }

    @Test func dispositionWithFilename() {
        let disposition = ContentDisposition(.formData, .name("file"), .filename("image.png"))
        #expect(disposition.value.contains("form-data"))
        #expect(disposition.value.contains("name=\"file\""))
        #expect(disposition.value.contains("filename=\"image.png\""))
    }

    @Test func dispositionWithUTF8Filename() {
        let disposition = ContentDisposition(.formData, .filename("文件.txt", encoding: .utf8))
        #expect(disposition.value.contains("filename*=UTF-8''"))
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
        let contentType = form.contentType

        #expect(contentType.field == "Content-Type")
        #expect(contentType.value.contains("multipart/form-data"))
        #expect(contentType.value.contains("boundary"))
        #expect(contentType.value.contains("MyBoundary"))
    }

    @Test func emptyFormData() {
        let form = MultiPartForm(boundary: "Boundary", fields: [])
        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("--Boundary--"))
    }

    @Test func singleTextField() {
        let form = MultiPartForm(boundary: "Boundary") {
            Text("Hello")
                .contentDisposition(.formData, .name("message"))
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
                .contentDisposition(.formData, .name("field1"))
            Text("Value2")
                .contentDisposition(.formData, .name("field2"))
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
                .contentDisposition(.formData, .name("data"))
                .contentType(.json)
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("Content-Type: application/json"))
    }

    @Test func fileFieldWithHeaders() {
        let imageData = Data("FakeImageData".utf8)
        let form = MultiPartForm(boundary: "Boundary") {
            File(data: imageData)
                .contentDisposition(.formData, .name("avatar"), .filename("profile.jpg"))
                .contentType(.jpeg)
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        #expect(dataString.contains("Content-Disposition: form-data; name=\"avatar\"; filename=\"profile.jpg\""))
        #expect(dataString.contains("Content-Type: image/jpeg"))
        #expect(dataString.contains("FakeImageData"))
    }

    @Test func headerOrderingContentDispositionFirst() {
        let form = MultiPartForm(boundary: "Boundary") {
            Text("Test")
                .contentType(.text)
                .contentDisposition(.formData, .name("field"))
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
    let baseURL = URL(string: "https://api.example.com")!

    @Test func requestWithMultiPartForm() throws {
        let request = Post<Data>("upload")
            .multiPartForm(boundary: "TestBoundary") {
                Text("Hello")
                    .contentDisposition(.formData, .name("message"))
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)

        let contentType = try #require(urlRequest.value(forHTTPHeaderField: "Content-Type"))
        #expect(contentType.contains("multipart/form-data"))
        #expect(contentType.contains("boundary"))

        let body = try #require(urlRequest.httpBody)
        let bodyString = try #require(String(data: body, encoding: .utf8))
        #expect(bodyString.contains("Hello"))
    }

    @Test func complexFormUpload() throws {
        let request = Post<Data>("upload")
            .multiPartForm(boundary: "ComplexBoundary") {
                Text("John Doe")
                    .contentDisposition(.formData, .name("fullName"))
                    .contentType(.text)

                Text("john@example.com")
                    .contentDisposition(.formData, .name("email"))

                File(data: Data("ProfileImageData".utf8))
                    .contentDisposition(.formData, .name("avatar"), .filename("avatar.png"))
                    .contentType(.png)

                File(data: Data("ResumeData".utf8))
                    .contentDisposition(.formData, .name("resume"), .filename("resume.pdf"))
                    .contentType(.pdf)
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let body = try #require(urlRequest.httpBody)
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
                    .contentDisposition(.formData, .name("required"))

                if includeOptional {
                    Text("Optional")
                        .contentDisposition(.formData, .name("optional"))
                }
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let body = try #require(urlRequest.httpBody)
        let bodyString = try #require(String(data: body, encoding: .utf8))

        #expect(bodyString.contains("Required"))
        #expect(bodyString.contains("Optional"))
    }

    @Test func formWithConditionalFieldsFalse() throws {
        let includeOptional = false

        let request = Post<Data>("upload")
            .multiPartForm(boundary: "Boundary") {
                Text("Required")
                    .contentDisposition(.formData, .name("required"))

                if includeOptional {
                    Text("Optional")
                        .contentDisposition(.formData, .name("optional"))
                }
            }

        let urlRequest = try request.urlRequest(baseURL: baseURL)
        let body = try #require(urlRequest.httpBody)
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
                .contentDisposition(.formData, .name("field"))
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        // Each field should be preceded by --boundary
        #expect(dataString.contains("--ABC123\r\n"))

        // Form should end with --boundary--
        #expect(dataString.contains("--ABC123--"))
    }

    @Test func multipleFieldBoundaries() {
        let form = MultiPartForm(boundary: "SEP") {
            Text("A").contentDisposition(.formData, .name("a"))
            Text("B").contentDisposition(.formData, .name("b"))
            Text("C").contentDisposition(.formData, .name("c"))
        }

        let dataString = String(data: form.data, encoding: .utf8)!

        // Count boundary occurrences (3 fields + 1 closing = should have 3 "--SEP\r\n" and 1 "--SEP--")
        let boundaryCount = dataString.components(separatedBy: "--SEP\r\n").count - 1
        #expect(boundaryCount == 3)

        #expect(dataString.hasSuffix("--SEP--\r\n"))
    }
}
