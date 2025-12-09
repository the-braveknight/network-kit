//
//  MIMEType.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

public struct MIMEType: ExpressibleByStringLiteral, Sendable {
    public let type: `Type`
    public let subType: SubType
    public let parameters: [MIMETypeParameter]
    
    public var value: String {
        let value = "\(type.value)/\(subType.value)"
        
        if parameters.isEmpty {
            return value
        } else {
            return "\(value);\(parameters.map(\.value).joined(separator: ";"))"
        }
    }
    
    public init(type: Type, subType: SubType, parameters: [MIMETypeParameter] = []) {
        self.type = type
        self.subType = subType
        self.parameters = parameters
    }
    
    public init(type: `Type`, subType: SubType, parameters: MIMETypeParameter...) {
        self.init(type: type, subType: subType, parameters: parameters)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        let components = value.split(separator: ";", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard let typeSubtype = components.first else {
            preconditionFailure("Invalid MIME type format.")
        }
        
        let typeSubtypeParts = typeSubtype.split(separator: "/", maxSplits: 1)
        
        guard typeSubtypeParts.indices.contains(0) && typeSubtypeParts.indices.contains(1) else {
            preconditionFailure("Invalid MIME type format.")
        }
        
        self.type = Type(value: String(typeSubtypeParts[0]))
        self.subType = SubType(value: String(typeSubtypeParts[1]))
        
        // Parameters parsing
        if components.indices.contains(1) {
            let parametersString = components[1]
            self.parameters = parametersString.split(separator: ";").map { AnyMIMETypeParameter(stringLiteral: String($0)) }
        } else {
            self.parameters = []
        }
    }
}

extension MIMEType {
    public struct `Type`: ExpressibleByStringLiteral, Sendable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
        
        public init(stringLiteral value: StringLiteralType) {
            self.init(value: value)
        }
    }
    
    public struct SubType: ExpressibleByStringLiteral, Sendable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
        
        public init(stringLiteral value: StringLiteralType) {
            self.init(value: value)
        }
    }
}

// MARK: - Predefined Types and SubTypes
public extension MIMEType.`Type` {
    static let application: Self = "application"
    static let multipart : Self = "multipart"
    static let text: Self = "text"
    static let image: Self = "image"
    static let audio: Self = "audio"
    static let video: Self = "video"
}

public extension MIMEType.SubType {
    static let json: Self = "json"
    static let formData: Self = "form-data"
    static let html: Self = "html"
    static let plain: Self = "plain"
    static let xml: Self = "xml"
    static let css: Self = "css"
    static let javascript: Self = "javascript"
    static let png: Self = "png"
    static let jpeg: Self = "jpeg"
    static let gif: Self = "gif"
    static let webp: Self = "webp"
    static let pdf: Self = "pdf"
    static let mpeg: Self = "mpeg"
    static let wav: Self = "wav"
    static let avi: Self = "avi"
    static let problemJson: Self = "problem+json"
}

public extension MIMEType {
    static let json: Self = "application/json"
    static let xml: Self = "application/xml"
    static let urlencoded: Self = "application/x-www-form-urlencoded"
    static let text: Self = "text/plain"
    static let html: Self = "text/html"
    static let css: Self = "text/css"
    static let javascript: Self = "text/javascript"
    static let gif: Self = "image/gif"
    static let png: Self = "image/png"
    static let jpeg: Self = "image/jpeg"
    static let bmp: Self = "image/bmp"
    static let webp: Self = "image/webp"
    static let midi: Self = "audio/midi"
    static let mpeg: Self = "audio/mpeg"
    static let wav: Self = "audio/wav"
    static let pdf: Self = "application/pdf"
    static let problemJson: Self = "application/problem+json"
}

public protocol MIMETypeParameter: Sendable {
    var value: String { get }
}

public struct Name: MIMETypeParameter {
    public let name: String
    
    public var value: String {
        "name=\"\(name)\""
    }
    
    init(_ name: String) {
        self.name = name
    }
}

public extension MIMETypeParameter where Self == Name {
    static func name(_ name: String) -> Self {
        Self(name)
    }
}

public struct Filename: MIMETypeParameter {
    public let filename: String
    public let encoding: Encoding?
    
    public enum Encoding: String, Sendable {
        case utf8
    }
    
    public var value: String {
        switch encoding {
        case .utf8:
            return "filename*=UTF-8''\(filename)"
            
        case nil:
            return "filename=\"\(filename)\""
        }
    }
    
    public init(_ filename: String, encoding: Encoding?) {
        self.filename = filename
        self.encoding = encoding
    }
}

public extension MIMETypeParameter where Self == Filename {
    static func filename(_ filename: String, encoding: Filename.Encoding? = nil) -> Self {
        Self(filename, encoding: encoding)
    }
}

public struct Boundary: MIMETypeParameter {
    public let boundary: String
    
    public var value: String {
        "boundary=\"\(boundary)\""
    }
    
    public init(_ boundary: String) {
        self.boundary = boundary
    }
}

public extension MIMETypeParameter where Self == Boundary {
    static func boundary(_ boundary: String) -> Self {
        Self(boundary)
    }
}

public struct AnyMIMETypeParameter: MIMETypeParameter, ExpressibleByStringLiteral {
    public let value: String
    
    public init(key: String, value: String) {
        self.value = "\(key)=\(value)"
    }
    
    public init(stringLiteral value: StringLiteralType) {
        let components = value.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.indices.contains(0) && components.indices.contains(1) else {
            preconditionFailure("Invalid parameter format. Expected 'key=value'.")
        }
        
        self.init(key: components[0], value: components[1])
    }
}
