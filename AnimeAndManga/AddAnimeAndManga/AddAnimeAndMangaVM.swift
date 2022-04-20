//
//  AddAnimeAndMangaVM.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/20.
//

import Foundation
import RxSwift

class AddAnimeAndMangaVM {
    let setAnimeMangaSubject = PublishSubject<Void>()

    func setAnimeManga(_ newAnime: UiAnime) {
        UserDefaultManager.shared.setCustomizeAnimeManga(newAnime)
        
        if newAnime.isFavorite {
            var favoriteList = getFavoriteList()
            favoriteList.append(newAnime.id)
            setFavoriteList(favoriteList)
        }
        
        setAnimeMangaSubject.onNext(())
    }
    
    func getAnimeManga() -> [UiAnime] {
        UserDefaultManager.shared.getCustomizeAnimeManga()
    }
    
    private func getFavoriteList() -> [Int] {
        return UserDefaultManager.shared.getFavoriteList()
    }

    private func setFavoriteList(_ list: [Int]) {
        UserDefaultManager.shared.setFavoriteList(list)
    }
}
