//
//  MangaRespModel.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/21.
//

import Foundation

struct MangaRespModel: Decodable {
    let pagination: Pagination
    let data: [MangaData]
}

struct MangaData: Decodable {
    let mal_id: Int
    let url: String
    let images: Images
    let title: String
    let title_english: String?
    let title_japanese: String
    let title_synonyms: [String]
    let type: String
    let chapters: Int?
    let volumes: Int?
    let status: String
    let publishing: Bool
    let published: Published
    let score: Double
    let scored: Double
    let scored_by: Int
    let rank: Int
    let popularity: Int
    let members: Int
    let favorites: Int
    let synopsis: String
    let background: String?
    let authors: [PersonInfo]
    let serializations: [PersonInfo]
    let genres: [PersonInfo]
    let explicit_genres: [PersonInfo]
    let themes: [PersonInfo]
    let demographics: [PersonInfo]
}

struct Published: Decodable {
    let from: String
    let to: String?
    let prop: Prop
    let string: String
}
