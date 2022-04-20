//
//  UserDefaultManager.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/20.
//

import Foundation

enum UserDefaultKey: String {
    case favoriteList
    case customizeAnimeManga
}

class UserDefaultManager {
    static let shared = UserDefaultManager()
    
    func getFavoriteList() -> [Int] {
        return UserDefaults.standard.object(forKey: UserDefaultKey.favoriteList.rawValue) as? [Int] ?? []
    }

    func setFavoriteList(_ list: [Int]) {
        UserDefaults.standard.set(list, forKey: UserDefaultKey.favoriteList.rawValue)
    }
    
    func getCustomizeAnimeManga() -> [UiAnime] {
        if let data = UserDefaults.standard.value(forKey: UserDefaultKey.customizeAnimeManga.rawValue) as? Data {
            let uiAnimeList = try? PropertyListDecoder().decode(Array<UiAnime>.self, from: data)
            return uiAnimeList ?? []
        }
        else {
            return []
        }
    }
    
    func setCustomizeAnimeManga(_ newAnime: UiAnime) {
        var uiAnimeList = getCustomizeAnimeManga()
        uiAnimeList.append(newAnime)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(uiAnimeList), forKey: UserDefaultKey.customizeAnimeManga.rawValue)
    }
    
}
