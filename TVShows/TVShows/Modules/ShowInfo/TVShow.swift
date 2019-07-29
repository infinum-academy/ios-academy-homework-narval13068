//
//  Show.swift
//  TVShows
//
//  Created by Rino Čala on 20/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation

// MARK - Codable structs for API calls

struct Show: Codable {
    
    let id: String
    let title: String
    let imageUrl: String
    let likesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case imageUrl
        case likesCount
    }
}

struct ShowDetails: Codable {
    
    let type: String
    let title: String
    let description: String
    let id: String
    let likesCount: Int
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case id = "_id"
        case likesCount
        case imageUrl
    }
}

struct Episode: Codable {
    
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let episodeNumber: String
    let season: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case imageUrl
        case episodeNumber
        case season
    }
}

struct NewEpisode: Codable {
    
    let showId: String
    let title: String
    let description: String
    let episodeNumber: String
    let season: String
    let type: String
    let id: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case showId
        case title
        case description
        case episodeNumber
        case season
        case type
        case id = "_id"
        case imageUrl
    }
}

struct Media: Codable {
    let path: String
    let type: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case path
        case type
        case id = "_id"
    }
}

struct EpisodeDetails: Codable {
    let showId: String
    let title: String
    let description: String
    let episodeNumber: String
    let season: String
    let type: String
    let id: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case showId
        case title
        case description
        case episodeNumber
        case season
        case type
        case id = "_id"
        case imageUrl
    }
}

struct Comment: Codable {
    let episodeId: String
    let text: String
    let userEmail: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case episodeId
        case text
        case userEmail
        case id = "_id"
    }
}

struct NewComment: Codable {
    let text: String
    let episodeId: String
    let userId: String
    let userEmail: String
    let type: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case episodeId
        case userId
        case userEmail
        case type
        case id = "_id"
    }
}
