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
    
    func getAnimeFavoriteList() -> [Int] {
        return UserDefaults.standard.object(forKey: UserDefaultKey.AnimeFavoriteList.rawValue) as? [Int] ?? []
    }

    func setAnimeFavoriteList(_ list: [Int]) {
        UserDefaults.standard.set(list, forKey: UserDefaultKey.AnimeFavoriteList.rawValue)
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
    
    func getMangaFavoriteList() -> [Int] {
        return UserDefaults.standard.object(forKey: UserDefaultKey.MangaFavoriteList.rawValue) as? [Int] ?? []
    }

    func setMangaFavoriteList(_ list: [Int]) {
        UserDefaults.standard.set(list, forKey: UserDefaultKey.MangaFavoriteList.rawValue)
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
