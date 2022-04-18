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
    private var allUiAnime = [UiAnime]()
    private var pageStatus: PageStatus = .NotLoadingMore
    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnime>]>()

    func getScheduleViewObject(page: Int) {
        pageStatus = .LoadingMore
        self.tableViewDataSubject.onNext(genSectionModel(viewObject: allUiAnime))
        
        APIManager.shared.getAnime(page: String(page)).map { [weak self] viewObject -> [UiAnime] in
            return self?.genUiAnimeList(viewObject: viewObject) ?? []
        }
        .subscribe(onSuccess: { [weak self] viewObject in
            self?.pageStatus = .NotLoadingMore
            self?.tableViewDataSubject.onNext((self?.genSectionModel(viewObject: viewObject))!)
        }, onFailure: { [weak self] err in
            print(err)
            self?.tableViewDataSubject.onError(err)
        }).disposed(by: disposeBag)
    }

    func setFavorite(anime: UiAnime) {
        var favoriteList: [Int] = getFavoriteList()

        if anime.isFavorite {
            favoriteList = favoriteList.filter({$0 != anime.id})
        }
        else {
            favoriteList.append(anime.id)
        }

        setFavoriteList(favoriteList)

        allUiAnime = allUiAnime.map { uiAnime -> UiAnime in
            if uiAnime.id == anime.id {
                return .init(id: anime.id, image: anime.image, title: anime.title, rank: anime.rank, startDate: anime.startDate, endDate: anime.endDate, isFavorite: !anime.isFavorite)
            }
            else {
                return uiAnime
            }
        }
        
        tableViewDataSubject.onNext((genSectionModel(viewObject: allUiAnime)))
    }
    
    func getPageStatus() -> PageStatus {
        return pageStatus
    }

    private func genUiAnimeList(viewObject: AnimeRespModel) -> [UiAnime] {
        let favoriteList: [Int] = getFavoriteList()

        let newUiAnimeList = viewObject.data.map { data -> UiAnime in
            let id = data.mal_id
            let isFavorite = favoriteList.contains(id)
            
            return .init(id: id, image: data.images.jpg.image_url ?? "noImage", title: data.title, rank: String(data.rank), startDate: data.aired.from.components(separatedBy: "T").first ?? data.aired.from, endDate: (data.aired.to ?? "nowT").components(separatedBy: "T").first ?? "now", isFavorite: isFavorite)
        }
        
        allUiAnime += newUiAnimeList
        
        allUiAnime = allUiAnime.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
        
        return allUiAnime
    }
    
    private func genSectionModel(viewObject: [UiAnime]) -> [SectionModel<String, UiAnime>] {
        
        var sectionModel = [viewObject].map({ return SectionModel(model: CellType.AnimeAndManga.rawValue, items: $0)})
        if getPageStatus() == .LoadingMore {
            sectionModel.append(.init(model: CellType.Loading.rawValue, items: [.init(id: 0, image: "", title: "", rank: "", startDate: "", endDate: "", isFavorite: false)]))
        }
        
        return sectionModel
    }
    
    private func getFavoriteList() -> [Int] {
        return UserDefaults.standard.object(forKey: "favoriteList") as? [Int] ?? []
    }

    private func setFavoriteList(_ list: [Int]) {
        UserDefaults.standard.set(list, forKey: "favoriteList")
    }
}
