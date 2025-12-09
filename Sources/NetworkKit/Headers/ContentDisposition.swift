//
//  ContentDisposition.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 3/6/25.
//

public struct ContentDisposition: HTTPHeader {
    public let field: String = "Content-Disposition"
    public let disposition: Disposition
    
    public var value: String {
        disposition.value
    }
    
    public init(_ dispositionType: Disposition) {
        self.disposition = dispositionType
    }
    
    public init(_ disposition: Disposition.`Type`, parameters: [MIMETypeParameter]) {
        self.disposition = Disposition(type: disposition, parameters: parameters)
    }
    
    public init(_ disposition: Disposition.`Type`, _ parameters: MIMETypeParameter...) {
        self.init(disposition, parameters: parameters)
    }
    
    public init(_ disposition: Disposition.`Type`, @MIMETypeParameterBuilder parameters: () -> [MIMETypeParameter]) {
        self.init(disposition, parameters: parameters())
    }
}

/// Result builder for constructing arrays of MIME type parameters.
@resultBuilder
public enum MIMETypeParameterBuilder {
    public static func buildExpression(_ element: MIMETypeParameter) -> [MIMETypeParameter] {
        [element]
    }

    public static func buildOptional(_ component: [MIMETypeParameter]?) -> [MIMETypeParameter] {
        component ?? []
    }

    public static func buildEither(first component: [MIMETypeParameter]) -> [MIMETypeParameter] {
        component
    }

    public static func buildEither(second component: [MIMETypeParameter]) -> [MIMETypeParameter] {
        component
    }

    public static func buildArray(_ components: [[MIMETypeParameter]]) -> [MIMETypeParameter] {
        components.flatMap { $0 }
    }

    public static func buildBlock(_ components: [MIMETypeParameter]...) -> [MIMETypeParameter] {
        components.flatMap { $0 }
    }
}

public struct Disposition: Sendable {
    public let type: Type
    public let parameters: [MIMETypeParameter]
    
    public init(type: Type, parameters: [MIMETypeParameter]) {
        self.type = type
        self.parameters = parameters
    }
    
    public init(type: Type, _ parameters: MIMETypeParameter...) {
        self.init(type: type, parameters: parameters)
    }
    
    public var value: String {
        if parameters.isEmpty {
            return type.rawValue
        } else {
            return "\(type.rawValue); \(parameters.map(\.value).joined(separator: "; "))"
        }
    }
}

public extension Disposition {
    enum `Type`: String, Sendable {
        case formData = "form-data"
        case inline
        case attachment
    }
}
