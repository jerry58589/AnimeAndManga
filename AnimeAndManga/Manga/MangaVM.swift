//
//  MangaVM.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/21.
//

import Foundation
import RxSwift
import RxDataSources

class MangaVM {
    private let disposeBag = DisposeBag()
    private var apiAnimeList = [UiAnime]()
    private var pageStatus: PageStatus = .NotLoadingMore
//    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnime>]>()

    func getNewPage(_ page: Int) {
    
//        APIManager.shared.getAnime(page: String(page)).map { [weak self] viewObject -> [UiAnime] in
//
//        }
        
        APIManager.shared.getManga(page: String(page)).map { [weak self] viewObject -> [UiAnime] in
            return self?.genUiAnimeList(viewObject) ?? []
        }
        .subscribe(onSuccess: { [weak self] newUiAnimeList in
//            self?.pageStatus = .NotLoadingMore
            self?.apiAnimeList += newUiAnimeList
//            self?.updateSectionModel()
        }, onFailure: { [weak self] err in
            print(err)
//            self?.tableViewDataSubject.onError(err)
        }).disposed(by: disposeBag)

    }
    
    private func genUiAnimeList(_ viewObject: MangaRespModel) -> [UiAnime] {
//        let favoriteList: [Int] = getFavoriteList()

        return viewObject.data.map { data -> UiAnime in
            let id = data.mal_id
//            let isFavorite = favoriteList.contains(id)
            
            return .init(id: id, imageUrl: data.images.jpg.image_url ?? "noImage", title: data.title, rank: String(data.rank), startDate: data.published.from.components(separatedBy: "T").first ?? data.published.from, endDate: (data.published.to ?? "nowT").components(separatedBy: "T").first ?? "now", url: data.url, isFavorite: false)
        }
    }

    
}
