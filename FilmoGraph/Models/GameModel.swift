//
//  GameModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation

struct Welcome: Codable {
    var count: Int?
    var next: String?
    var pervious: String?
    var results: [Game]
}

struct Game: Codable {
    
    var id: Int?
    var slug: String?
    var name: String?
    var released: Date?
    var tba: Bool?
    var backgroundImage: String?
    var rating: Float?
    var ratingTop: Int?
    var ratings: Ratings?
    var ratingsCount: Int?
    var reviewsTextCount: Int?
    var added: Int?
    var addedByStatus: AddedByStatus?
    var metacritic: Int?
    var playtime: Int?
    var suggestionsCount: Int?
    var updated: Date?
    var esrbRating: EsrbRating?
    var platforms: [Platforms]?
    
}

struct Platforms: Codable {
    var platform: Platform?
    var releasedAt: String?
    var requirements: Requirements?
}

struct Platform: Codable {
    var id: Int?
    var slug: String?
    var name: String?
}

struct Requirements: Codable {
    var minimum: String?
    var recommended: String?
}

struct EsrbRating: Codable {
    let id: Int?
    let slug: String?
    let name: String?
}

struct Ratings: Codable {
    
}

struct AddedByStatus: Codable {
    
    var beaten: Int?
    var dropped: Int?
    var owned: Int?
    var playing: Int?
    var toplay: Int?
    var yet: Int?
    
}
