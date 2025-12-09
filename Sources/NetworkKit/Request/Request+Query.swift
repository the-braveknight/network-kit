//
//  Request+Query.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

extension Request {
    /// Adds query parameters to the request URL using a result builder.
    ///
    /// ```swift
    /// Get<[User]>("users")
    ///     .queries {
    ///         Query(name: "page", value: "1")
    ///         Query(name: "limit", value: "20")
    ///     }
    /// ```
    public func queries(@QueryBuilder _ builder: () -> [Query]) -> Self {
        var copy = self
        copy.components.queryItems.append(contentsOf: builder())
        return copy
    }

    /// Adds a single query parameter to the request.
    public func query(name: String, value: String?) -> Self {
        var copy = self
        copy.components.queryItems.append(Query(name: name, value: value))
        return copy
    }
}

// MARK: - Result Builder

/// Result builder for constructing arrays of query parameters.
@resultBuilder
public struct QueryBuilder {
    public static func buildExpression(_ query: Query) -> [Query] {
        [query]
    }

    public static func buildOptional(_ component: [Query]?) -> [Query] {
        component ?? []
    }

    public static func buildEither(first component: [Query]) -> [Query] {
        component
    }

    public static func buildEither(second component: [Query]) -> [Query] {
        component
    }

    public static func buildArray(_ components: [[Query]]) -> [Query] {
        components.flatMap { $0 }
    }

    public static func buildBlock(_ components: [Query]...) -> [Query] {
        components.flatMap { $0 }
    }
}
