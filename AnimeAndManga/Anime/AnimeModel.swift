//
//  AnimeModel.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import Foundation

struct UiAnime: Codable {
    let id: Int
    let imageUrl: String
    let title: String
    let rank: String
    let startDate: String
    let endDate: String
    let url: String
    let isFavorite: Bool
}
