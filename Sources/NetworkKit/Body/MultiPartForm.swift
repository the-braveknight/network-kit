//
//  MultiPartForm.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 3/6/25.
//

import Foundation
import HTTPTypes

// MARK: - MultiPart Form Field Protocol

public protocol MultiPartFormField: Sendable {
    var headers: HTTPFields { get }
    var body: Data { get }
}

extension MultiPartFormField {
    public var headers: HTTPFields { HTTPFields() }
}

// MARK: - MultiPart Form Field With Additional Headers

public struct MultiPartFormFieldWithAdditionalHeaders<Field: MultiPartFormField>: MultiPartFormField {
    public let headers: HTTPFields
    public let body: Data

    init(field: Field, additionalHeaders: HTTPFields) {
        var combined = field.headers
        for header in additionalHeaders {
            combined[header.name] = header.value
        }
        self.headers = combined
        self.body = field.body
    }
}

// MARK: - MultiPart Form Field Extensions for Headers

extension MultiPartFormField {
    /// Adds a Content-Disposition header with form-data disposition.
    ///
    /// - Parameters:
    ///   - name: The form field name
    ///   - filename: Optional filename for file uploads
    public func contentDisposition(name: String, filename: String? = nil) -> some MultiPartFormField {
        var value = "form-data; name=\"\(name)\""
        if let filename = filename {
            value += "; filename=\"\(filename)\""
        }
        var headers = HTTPFields()
        headers[.contentDisposition] = value
        return MultiPartFormFieldWithAdditionalHeaders(field: self, additionalHeaders: headers)
    }

    /// Adds a Content-Type header.
    ///
    /// - Parameter mimeType: The MIME type string (e.g., "image/png", "application/json")
    public func contentType(_ mimeType: String) -> some MultiPartFormField {
        var headers = HTTPFields()
        headers[.contentType] = mimeType
        return MultiPartFormFieldWithAdditionalHeaders(field: self, additionalHeaders: headers)
    }
}

// MARK: - MultiPart Form Structure

public struct MultiPartForm: Sendable {
    public let boundary: String
    public let fields: [MultiPartFormField]

    public var data: Data {
        var data = Data()
        let boundaryData = "--\(boundary)\r\n".data(using: .utf8)!
        let closingBoundaryData = "--\(boundary)--\r\n".data(using: .utf8)!

        for field in fields {
            data.append(boundaryData)

            // Sort headers so Content-Disposition comes first
            let sortedHeaders = field.headers.sorted {
                $0.name == .contentDisposition && $1.name != .contentDisposition
            }

            for header in sortedHeaders {
                data.append("\(header.name): \(header.value)\r\n".data(using: .utf8)!)
            }

            data.append("\r\n".data(using: .utf8)!)
            data.append(field.body)
            data.append("\r\n".data(using: .utf8)!)
        }

        data.append(closingBoundaryData)
        return data
    }

    public init(boundary: String, fields: [MultiPartFormField]) {
        self.boundary = boundary
        self.fields = fields
    }

    public init(boundary: String, @MultiPartFormFieldBuilder fields: () -> [MultiPartFormField]) {
        self.init(boundary: boundary, fields: fields())
    }

    /// The Content-Type header value for this multipart form.
    public var contentTypeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }
}

// MARK: - Text Form Field

public struct Text: MultiPartFormField {
    public let value: String

    public var body: Data {
        Data(value.utf8)
    }

    public init(_ value: String) {
        self.value = value
    }
}

// MARK: - File Form Field

public struct File: MultiPartFormField {
    public let body: Data

    public init(data: Data) {
        self.body = data
    }
}

// MARK: - Request Extension for MultiPartForm

extension Request {
    /// Sets the request body to a multipart form.
    ///
    /// ```swift
    /// Post<Response>("upload")
    ///     .multiPartForm(boundary: "Boundary-\(UUID().uuidString)") {
    ///         Text("Hello")
    ///             .contentDisposition(name: "message")
    ///         File(data: imageData)
    ///             .contentDisposition(name: "file", filename: "image.png")
    ///             .contentType("image/png")
    ///     }
    /// ```
    public func multiPartForm(boundary: String, @MultiPartFormFieldBuilder fields: () -> [MultiPartFormField]) -> Self {
        let form = MultiPartForm(boundary: boundary, fields: fields)
        var copy = self
        copy.components.body = form.data
        copy.components.headerFields[.contentType] = form.contentTypeValue
        return copy
    }
}

// MARK: - Result Builders

/// Result builder for constructing arrays of multipart form fields.
@resultBuilder
public enum MultiPartFormFieldBuilder {
    public static func buildExpression(_ element: some MultiPartFormField) -> [MultiPartFormField] {
        [element]
    }

    public static func buildOptional(_ component: [MultiPartFormField]?) -> [MultiPartFormField] {
        component ?? []
    }

    public static func buildEither(first component: [MultiPartFormField]) -> [MultiPartFormField] {
        component
    }

    public static func buildEither(second component: [MultiPartFormField]) -> [MultiPartFormField] {
        component
    }

    public static func buildArray(_ components: [[MultiPartFormField]]) -> [MultiPartFormField] {
        components.flatMap { $0 }
    }

    public static func buildBlock(_ components: [MultiPartFormField]...) -> [MultiPartFormField] {
        components.flatMap { $0 }
    }
}
