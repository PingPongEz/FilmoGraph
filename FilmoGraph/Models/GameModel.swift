//
//  GameModel.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import Foundation

// MARK: - Welcome
struct GameDetais: Codable {
    let id: Int?
    let slug: String?
    let name: String?
    let nameOriginal: String?
    let description: String?
    let metacritic: Int?
    let metacriticPlatforms: [MetacriticPlatform]?
    let released: String?
    let tba: Bool?
    let updated: Date?
    let backgroundImage: String?
    let backgroundImageAdditional: String?
    let website: String?
    let rating: Float?
    let ratingTop: Float?
    let ratings: [AddedByStatus]?
    let reactions: AddedByStatus?
    let added: Int?
    let addedByStatus: AddedByStatus?
    let playtime: Int?
    let screenshotsCount: Int?
    let moviesCount: Int?
    let creatorsCount: Int?
    let achievementsCount: Int?
    let parentAchievementsCount: Int?
    let redditURL: String?
    let redditName: String?
    let redditDescription: String?
    let redditLogo: String?
    let redditCount: Int?
    let twitchCount: Int?
    let youtubeCount: Int?
    let reviewsTextCount: Int?
    let ratingsCount: Int?
    let suggestionsCount: Int?
    let alternativeNames: [String]?
    let metacriticURL: String?
    let parentsCount: Int?
    let additionsCount: Int?
    let gameSeriesCount: Int?
    let esrbRating: EsrbRating?
    let platforms: [Platforms]?
}



struct Welcome: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [Game]
}

struct Publishers: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [Publisher]
}

struct Publisher: Codable {
    let id: Int?
    let name: String?
    let slug: String?
    let gamesCount: Int?
    let imageBackground: String?
}

struct Game: Codable {
    
    let id: Int?
    let slug: String?
    let name: String?
    let released: Date?
    let tba: Bool?
    let backgroundImage: String?
    let rating: Float?
    let ratingTop: Int?
    let ratings: Ratings?
    let ratingsCount: Int?
    let reviewsTextCount: Int?
    let added: Int?
    let addedByStatus: AddedByStatus?
    let metacritic: Int?
    let playtime: Int?
    let suggestionsCount: Int?
    let updated: Date?
    let esrbRating: EsrbRating?
    let platforms: [Platforms]?
    let genres: [Genre]?
}

//MARK: Platforms
struct Platforms: Codable {
    let platform: Platform?
    let releasedAt: String?
    let requirements: Requirements?
}

struct AllPlatforms: Codable {
    let next: String?
    let results: [Platform]?
}

struct Platform: Codable {
    let id: Int?
    let slug: String?
    let name: String?
}

//MARK: Requerments
struct Requirements: Codable {
    let minimum: String?
    let recommended: String?
}


struct EsrbRating: Codable {
    let id: Int?
    let slug: String?
    let name: String?
}

struct Ratings: Codable {
    
}

struct AddedByStatus: Codable {
    let beaten: Int?
    let dropped: Int?
    let owned: Int?
    let playing: Int?
    let toplay: Int?
    let yet: Int?
}

// MARK: - MetacriticPlatform
struct MetacriticPlatform: Codable {
    let metascore: Int?
    let url: String?
}

// MARK: - Welcome
struct ScreenShots: Codable {
    let count: Int?
    let next, previous: String?
    let results: [ScreenShotsResult]?
}

// MARK: - Result
struct ScreenShotsResult: Codable {
    let image: String?
    let hidden: Bool?
}

//platforms stores developers publishers

//MARK: Genres
struct Genres: Codable {
    let count: Int?
    let results: [Genre]?
}

struct Genre: Codable {
    let id: Int?
    let name: String?
    let slug: String?
    let gamesCount: Int?
    let imageBackground: String?
}

