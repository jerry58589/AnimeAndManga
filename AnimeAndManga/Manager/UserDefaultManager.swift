//
//  UserDefaultManager.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/20.
//

import Foundation

enum UserDefaultKey: String {
    case AnimeFavoriteList
    case MangaFavoriteList
    case AnimeCustomizeList
    case MangaCustomizeList
}

class UserDefaultManager {
    static let shared = UserDefaultManager()

    func getAnimeFavoriteList() -> [UiFavorite] {
        if let data = UserDefaults.standard.value(forKey: UserDefaultKey.AnimeFavoriteList.rawValue) as? Data {
            let uiFavoriteList = try? PropertyListDecoder().decode(Array<UiFavorite>.self, from: data)
            return uiFavoriteList ?? []
        }
        else {
            return []
        }
    }

    func setAnimeFavoriteList(_ list: [UiFavorite]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(list), forKey: UserDefaultKey.AnimeFavoriteList.rawValue)
    }
    
    func getAnimeCustomizeList() -> [UiAnimeManga] {
        if let data = UserDefaults.standard.value(forKey: UserDefaultKey.AnimeCustomizeList.rawValue) as? Data {
            let uiAnimeList = try? PropertyListDecoder().decode(Array<UiAnimeManga>.self, from: data)
            return uiAnimeList ?? []
        }
        else {
            return []
        }
    }
    
    func setAnimeCustomizeList(_ newAnime: UiAnimeManga) {
        var uiAnimeList = getAnimeCustomizeList()
        uiAnimeList.append(newAnime)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(uiAnimeList), forKey: UserDefaultKey.AnimeCustomizeList.rawValue)
    }
    
    func getMangaFavoriteList() -> [UiFavorite] {
        if let data = UserDefaults.standard.value(forKey: UserDefaultKey.MangaFavoriteList.rawValue) as? Data {
            let uiFavoriteList = try? PropertyListDecoder().decode(Array<UiFavorite>.self, from: data)
            return uiFavoriteList ?? []
        }
        else {
            return []
        }
    }

    func setMangaFavoriteList(_ list: [UiFavorite]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(list), forKey: UserDefaultKey.MangaFavoriteList.rawValue)
    }
    
    func getMangaCustomizeList() -> [UiAnimeManga] {
        if let data = UserDefaults.standard.value(forKey: UserDefaultKey.MangaCustomizeList.rawValue) as? Data {
            let uiAnimeList = try? PropertyListDecoder().decode(Array<UiAnimeManga>.self, from: data)
            return uiAnimeList ?? []
        }
        else {
            return []
        }
    }
    
    func setMangaCustomizeList(_ newAnime: UiAnimeManga) {
        var uiAnimeList = getMangaCustomizeList()
        uiAnimeList.append(newAnime)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(uiAnimeList), forKey: UserDefaultKey.MangaCustomizeList.rawValue)
    }
    
}
