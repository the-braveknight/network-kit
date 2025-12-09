//
//  User.swift
//  Example
//
//  Created by Zaid Rahhawi on 4/8/24.
//

import Foundation
import SwiftData

@Model
final class User: Decodable, Identifiable, Sendable {
    @Attribute(.unique) var id: Int
    var name: String
    var email: String
    var gender: Gender
    var status: Status
    
    enum Gender: String, Codable {
        case male, female
    }
    
    enum Status: String, Codable {
        case active, inactive
    }
    
    init(id: Int, name: String, email: String, gender: Gender, status: Status) {
        self.id = id
        self.name = name
        self.email = email
        self.gender = gender
        self.status = status
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, email, gender, status
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.gender = try container.decode(Gender.self, forKey: .gender)
        self.status = try container.decode(Status.self, forKey: .status)
    }
}
