//
//  User.swift
//  TVShows
//
//  Created by Rino Čala on 14/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation

// MARK - Codable struct for API calls

struct User: Codable {
    
    let email: String
    let type: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case type
        case id = "_id"
    }
}

struct LoginUser : Codable {
    let token: String
}
