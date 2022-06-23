//
//  GameModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation

// MARK: - Welcome
struct GameDetais: Codable {
    var id: Int?
    var slug: String?
    var name: String?
    var nameOriginal: String?
    var description: String?
    var metacritic: Int?
    var metacriticPlatforms: [MetacriticPlatform]?
    var released: String?
    var tba: Bool?
    var updated: Date?
    var backgroundImage: String?
    var backgroundImageAdditional: String?
    var website: String?
    var rating: Float?
    var ratingTop: Float?
    var ratings: [AddedByStatus]?
    var reactions: AddedByStatus?
    var added: Int?
    var addedByStatus: AddedByStatus?
    var playtime: Int?
    var screenshotsCount: Int?
    var moviesCount: Int?
    var creatorsCount: Int?
    var achievementsCount: Int?
    var parentAchievementsCount: Int?
    var redditURL: String?
    var redditName: String?
    var redditDescription: String?
    var redditLogo: String?
    var redditCount: Int?
    var twitchCount: Int?
    var youtubeCount: Int?
    var reviewsTextCount: Int?
    var ratingsCount: Int?
    var suggestionsCount: Int?
    var alternativeNames: [String]?
    var metacriticURL: String?
    var parentsCount: Int?
    var additionsCount: Int?
    var gameSeriesCount: Int?
    var esrbRating: EsrbRating?
    var platforms: [Platforms]?
}

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
// MARK: - MetacriticPlatform
struct MetacriticPlatform: Codable {
    let metascore: Int
    let url: String
}
