//
//  GoRESTService.swift
//  Example
//
//  Created by Zaid Rahhawi on 12/24/24.
//

protocol GoRESTService: Sendable {
    func loadPosts(page: Int) async throws -> PaginatedResponse<Post>
    func loadTodos(page: Int) async throws -> PaginatedResponse<Todo>
    func loadUsers(page: Int) async throws -> PaginatedResponse<User>
}
