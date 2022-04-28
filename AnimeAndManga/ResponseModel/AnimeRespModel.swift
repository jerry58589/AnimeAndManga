//
//  AnimeRespModel.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import Foundation

struct AnimeRespModel: Decodable {
    let pagination: Pagination
    let data: [AnimeData]
}

struct Pagination: Decodable {
    let last_visible_page: Int
    let has_next_page: Bool
    let current_page: Int
    let items: Items
}

struct Items: Decodable {
    let count: Int
    let total: Int
    let per_page: Int
}

struct AnimeData: Decodable {
    let mal_id: Int
    let url: String
    let images: Images
    let trailer: Trailer
    let title: String
    let title_english: String?
    let title_japanese: String?
    let title_synonyms: [String]
    let type: String
    let source: String
    let episodes: Int?
    let status: String
    let airing: Bool
    let aired: Aired?
    let duration: String
    let rating: String
    let score: Double?
    let scored_by: Int?
    let rank: Int
    let popularity: Int
    let members: Int
    let favorites: Int
    let synopsis: String?
    let background: String?
    let season: String?
    let year: Int?
    let broadcast: Broadcast
    let producers: [PersonInfo]
    let licensors: [PersonInfo]
    let studios: [PersonInfo]
    let genres: [PersonInfo]
    let explicit_genres: [PersonInfo]
    let themes: [PersonInfo]
    let demographics: [PersonInfo]
}

struct Images: Decodable {
    let jpg: ImageInfo
    let webp: ImageInfo
}

struct ImageInfo: Decodable {
    let image_url: String?
    let small_image_url: String?
    let medium_image_url: String?
    let large_image_url: String?
    let maximum_image_url: String?
}

struct Trailer: Decodable {
    let youtube_id: String?
    let url: String?
    let embed_url: String?
    let images: ImageInfo
}

struct Aired: Decodable {
    let from: String?
    let to: String?
    let prop: Prop
    let string: String?
}

struct Prop: Decodable {
    let from: PropDate?
    let to: PropDate?
}

struct PropDate: Decodable {
    let day: Int?
    let month: Int?
    let year: Int?
}

struct Broadcast: Decodable {
    let day: String?
    let time: String?
    let timezone: String?
    let string: String?
}

struct PersonInfo: Decodable {
    let mal_id: Int
    let type: String
    let name: String
    let url: String
}

