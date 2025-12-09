//
//  Posts API.swift
//  NetworkingIdeas
//
//  Created by Zaid Rahhawi on 4/7/24.
//

import Foundation
import Melatonin

struct GetPosts: Endpoint {
    var user: User.ID? = nil
    var page: Int = 1
    var recordsPerPage: Int = 10
    var title: String? = nil

    var request: some Request<[Post]> {
        Get<[Post]>("posts")
            .queries {
                if let user {
                    Query(name: "user_id", value: String(user))
                }
                Query(name: "page", value: String(page))
                Query(name: "per_page", value: String(recordsPerPage))
                if let title {
                    Query(name: "title", value: title)
                }
            }
    }
}
