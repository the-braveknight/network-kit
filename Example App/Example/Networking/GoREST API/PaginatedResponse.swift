//
//  PaginatedResponse.swift
//  Example
//
//  Created by Zaid Rahhawi on 12/20/24.
//

import Foundation
import HTTPTypes

struct PaginationMetadata {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let recordsPerPage: Int

    init(totalCount: Int, totalPages: Int, recordsPerPage: Int, currentPage: Int) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalCount = totalCount
        self.recordsPerPage = recordsPerPage
    }

    init(from headerFields: HTTPFields) throws {
        guard let currentPageStr = headerFields[HTTPField.Name("x-pagination-page")!],
              let currentPage = Int(currentPageStr) else {
            throw NSError()
        }

        guard let totalPagesStr = headerFields[HTTPField.Name("x-pagination-pages")!],
              let totalPages = Int(totalPagesStr) else {
            throw NSError()
        }

        guard let totalCountStr = headerFields[HTTPField.Name("x-pagination-total")!],
              let totalCount = Int(totalCountStr) else {
            throw NSError()
        }

        guard let perPageStr = headerFields[HTTPField.Name("x-pagination-limit")!],
              let perPage = Int(perPageStr) else {
            throw NSError()
        }

        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalCount = totalCount
        self.recordsPerPage = perPage
    }
}

struct PaginatedResponse<Item> {
    let items: [Item]
    let pagination: PaginationMetadata
}

extension PaginationMetadata {
    var firstPage: Int {
        return 1
    }

    var lastPage: Int {
        return totalPages
    }

    var nextPage: Int? {
        guard currentPage < totalPages else {
            return nil
        }

        return currentPage + 1
    }

    var previousPage: Int? {
        guard currentPage > 1 else {
            return nil
        }

        return currentPage - 1
    }
}
