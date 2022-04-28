//
//  AddAnimeMangaVM.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/20.
//

import Foundation
import RxSwift

class AddAnimeMangaVM {
    private let type: PageType
    let setAnimeMangaSubject = PublishSubject<Void>()
    let titleSubject = ReplaySubject<String>.create(bufferSize: 1)

    init(type: PageType) {
        self.type = type
        
        if type == .Anime {
            self.titleSubject.onNext("Add anime")
        }
        else if type == .Manga {
            self.titleSubject.onNext("Add manga")
        }
    }
    
    func setAnimeManga(_ newAnime: UiAnimeManga) {
        if type == .Anime {
            UserDefaultManager.shared.setAnimeCustomizeList(newAnime)
        }
        else {
            UserDefaultManager.shared.setMangaCustomizeList(newAnime)
        }
        
        if newAnime.isFavorite {
            var favoriteList = getFavoriteList()
            favoriteList.append(.init(id: newAnime.id, rank: newAnime.rank))
            setFavoriteList(favoriteList)
        }
        
        setAnimeMangaSubject.onNext(())
    }
    
    func getAnimeManga() -> [UiAnimeManga] {
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeCustomizeList()
        }
        else {
            return UserDefaultManager.shared.getMangaCustomizeList()
        }
    }
    
    private func getFavoriteList() -> [UiFavorite] {
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeFavoriteList()
        }
        else {
            return UserDefaultManager.shared.getMangaFavoriteList()
        }
    }

    private func setFavoriteList(_ list: [UiFavorite]) {
        if type == .Anime {
            UserDefaultManager.shared.setAnimeFavoriteList(list)
        }
        else {
            UserDefaultManager.shared.setMangaFavoriteList(list)
        }
    }
}
