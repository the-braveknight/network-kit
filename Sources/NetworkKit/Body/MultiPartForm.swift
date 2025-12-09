//
//  MultiPartForm.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 3/6/25.
//

import Foundation

// MARK: - MultiPart Form Field Protocol

public protocol MultiPartFormField: Sendable {
    var headers: [MultiPartFormFieldHeader] { get }
    var body: Data { get }
}

extension MultiPartFormField {
    public var headers: [MultiPartFormFieldHeader] { [] }
}

// MARK: - MultiPart Form Field Header Protocol

public protocol MultiPartFormFieldHeader: Sendable {
    var fieldValue: String { get }
}

extension HTTPHeader where Self: MultiPartFormFieldHeader {
    public var fieldValue: String {
        "\(field): \(value)"
    }
}

// MARK: - Content-Type as a MultiPartFormFieldHeader

extension ContentType: MultiPartFormFieldHeader {}

// MARK: - Content-Disposition as a MultiPartFormFieldHeader

extension ContentDisposition: MultiPartFormFieldHeader {}

// MARK: - MultiPart Form Field With Additional Headers

public struct MultiPartFormFieldWithAdditionalHeaders<Field: MultiPartFormField>: MultiPartFormField {
    public let headers: [MultiPartFormFieldHeader]
    public let body: Data

    init(field: Field, headers: [MultiPartFormFieldHeader]) {
        self.headers = field.headers + headers
        self.body = field.body
    }
}

// MARK: - MultiPart Form Field Extensions for Headers

extension MultiPartFormField {
    public func contentDisposition(_ disposition: Disposition.`Type`, _ parameters: MIMETypeParameter...) -> some MultiPartFormField {
        MultiPartFormFieldWithAdditionalHeaders(field: self, headers: [ContentDisposition(disposition, parameters: parameters)])
    }

    public func contentDisposition(_ disposition: Disposition.`Type`, @MIMETypeParameterBuilder _ parameters: () -> [MIMETypeParameter]) -> some MultiPartFormField {
        MultiPartFormFieldWithAdditionalHeaders(field: self, headers: [ContentDisposition(disposition, parameters: parameters)])
    }

    public func contentType(_ mimeType: MIMEType) -> some MultiPartFormField {
        MultiPartFormFieldWithAdditionalHeaders(field: self, headers: [ContentType(mimeType)])
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

            let sortedHeaders = field.headers.sorted { $0 is ContentDisposition && !($1 is ContentDisposition) }

            for header in sortedHeaders {
                data.append("\(header.fieldValue)\r\n".data(using: .utf8)!)
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
    public var contentType: ContentType {
        ContentType(MIMEType(type: .multipart, subType: .formData, parameters: [Boundary(boundary)]))
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

    public init(filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: url) else {
            preconditionFailure("Could not read file at: \(filePath)")
        }
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
    ///             .contentDisposition(.formData, .name("message"))
    ///         File(data: imageData)
    ///             .contentDisposition(.formData, .name("file"), .filename("image.png"))
    ///             .contentType(.png)
    ///     }
    /// ```
    public func multiPartForm(boundary: String, @MultiPartFormFieldBuilder fields: () -> [MultiPartFormField]) -> Self {
        let form = MultiPartForm(boundary: boundary, fields: fields)
        var copy = self
        copy.components.body = form.data
        copy.components.headers.append(form.contentType)
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
