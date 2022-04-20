//
//  AnimeVM.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import Foundation
import RxSwift
import RxDataSources

enum PageStatus {
    case LoadingMore
    case NotLoadingMore
}

enum CellType: String {
    case AnimeAndManga
    case Loading
}

class AnimeVM {
    private let disposeBag = DisposeBag()
    private var apiAnimeList = [UiAnime]()
    private var pageStatus: PageStatus = .NotLoadingMore
    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnime>]>()

    func getNewPage(_ page: Int) {
        pageStatus = .LoadingMore
        updateSectionModel()
        
        APIManager.shared.getAnime(page: String(page)).map { [weak self] viewObject -> [UiAnime] in
            return self?.genUiAnimeList(viewObject) ?? []
        }
        .subscribe(onSuccess: { [weak self] newUiAnimeList in
            self?.pageStatus = .NotLoadingMore
            self?.apiAnimeList += newUiAnimeList
            self?.updateSectionModel()
        }, onFailure: { [weak self] err in
            print(err)
            self?.tableViewDataSubject.onError(err)
        }).disposed(by: disposeBag)
    }
    
    func setFavorite(_ anime: UiAnime) {
        var favoriteList: [Int] = getFavoriteList()

        if anime.isFavorite {
            favoriteList = favoriteList.filter({$0 != anime.id})
        }
        else {
            favoriteList.append(anime.id)
        }

        setFavoriteList(favoriteList)
        updateSectionModel()
    }
    
    func getPageStatus() -> PageStatus {
        return pageStatus
    }

    func updateSectionModel() {
        var newUiAnimeList = apiAnimeList
        
        newUiAnimeList += getCustomizeAnimeManga()
        newUiAnimeList = genFavoriteUiAnimeList(newUiAnimeList)
        newUiAnimeList = newUiAnimeList.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
        
        self.tableViewDataSubject.onNext(genSectionModel(newUiAnimeList))
    }
    
    private func genUiAnimeList(_ viewObject: AnimeRespModel) -> [UiAnime] {
        let favoriteList: [Int] = getFavoriteList()

        return viewObject.data.map { data -> UiAnime in
            let id = data.mal_id
            let isFavorite = favoriteList.contains(id)
            
            return .init(id: id, imageUrl: data.images.jpg.image_url ?? "noImage", title: data.title, rank: String(data.rank), startDate: data.aired.from.components(separatedBy: "T").first ?? data.aired.from, endDate: (data.aired.to ?? "nowT").components(separatedBy: "T").first ?? "now", url: data.url, isFavorite: isFavorite)
        }
    }

    private func genFavoriteUiAnimeList(_ animeList: [UiAnime]) -> [UiAnime] {
        let favoriteList = getFavoriteList()
        
        return animeList.map { uiAnime -> UiAnime in
            let isFavorite = favoriteList.contains(uiAnime.id)
            return .init(id: uiAnime.id, imageUrl: uiAnime.imageUrl, title: uiAnime.title, rank: uiAnime.rank, startDate: uiAnime.startDate, endDate: uiAnime.endDate, url: uiAnime.url, isFavorite: isFavorite)
        }
    }
    
    private func genSectionModel(_ viewObject: [UiAnime]) -> [SectionModel<String, UiAnime>] {
        var sectionModel = [viewObject].map({ return SectionModel(model: CellType.AnimeAndManga.rawValue, items: $0)})
        
        if getPageStatus() == .LoadingMore {
            sectionModel.append(.init(model: CellType.Loading.rawValue, items: [.init(id: 0, imageUrl: "", title: "", rank: "", startDate: "", endDate: "", url: "", isFavorite: false)]))
        }
        
        return sectionModel
    }
    
    private func getFavoriteList() -> [Int] {
        return UserDefaultManager.shared.getFavoriteList()
    }

    private func setFavoriteList(_ list: [Int]) {
        UserDefaultManager.shared.setFavoriteList(list)
    }
    
    private func getCustomizeAnimeManga() -> [UiAnime] {
        return UserDefaultManager.shared.getCustomizeAnimeManga()
    }
}
