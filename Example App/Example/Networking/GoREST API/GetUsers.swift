//
//  Users API.swift
//  NetworkingIdeas
//
//  Created by Zaid Rahhawi on 4/7/24.
//

import Foundation
import Melatonin

struct GetUsers: Endpoint {
    var page: Int = 1
    var recordsPerPage: Int = 10
    var name: String? = nil

    var request: some Request<[User]> {
        Get<[User]>("users")
            .queries {
                Query(name: "page", value: String(page))
                Query(name: "per_page", value: String(recordsPerPage))
                if let name {
                    Query(name: "name", value: name)
                }
            }
    }
}
