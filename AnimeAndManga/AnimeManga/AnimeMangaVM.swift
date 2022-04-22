//
//  AnimeMangaVM.swift
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

enum PageType {
    case Anime
    case Manga
}

class AnimeMangaVM {
    private let disposeBag = DisposeBag()
    private var apiAnimeMangaList = [UiAnimeManga]()
    private var pageStatus: PageStatus = .NotLoadingMore
    private let type: PageType
    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnimeManga>]>()
    let titleSubject = ReplaySubject<String>.create(bufferSize: 1)

    init(type: PageType) {
        self.type = type
        
        if type == .Anime {
            self.titleSubject.onNext("Anime")
        }
        else if type == .Manga {
            self.titleSubject.onNext("Manga")
        }
    }
    
    func getNewPage(_ page: Int) {
        pageStatus = .LoadingMore
        updateSectionModel()
        
        if type == .Anime {
            APIManager.shared.getAnime(page: String(page)).map { [weak self] (viewObject) -> [UiAnimeManga] in
                return self?.genAnimeUiList(viewObject) ?? []
            }
            .subscribe(onSuccess: { [weak self] (newUiAnimeList) in
                self?.pageStatus = .NotLoadingMore
                self?.apiAnimeMangaList += newUiAnimeList
                self?.updateSectionModel()
            }, onFailure: { [weak self] (err) in
                print(err)
                self?.tableViewDataSubject.onError(err)
            }).disposed(by: disposeBag)
        }
        else {
            APIManager.shared.getManga(page: String(page)).map { [weak self] (viewObject) -> [UiAnimeManga] in
                return self?.genMangaUiList(viewObject) ?? []
            }
            .subscribe(onSuccess: { [weak self] (newUiAnimeList) in
                self?.pageStatus = .NotLoadingMore
                self?.apiAnimeMangaList += newUiAnimeList
                self?.updateSectionModel()
            }, onFailure: { [weak self] (err) in
                print(err)
                self?.tableViewDataSubject.onError(err)
            }).disposed(by: disposeBag)

        }
    }
    
    func setFavorite(_ animeManga: UiAnimeManga) {
        var favoriteList: [Int] = getFavoriteList()
        
        if animeManga.isFavorite {
            favoriteList = favoriteList.filter({$0 != animeManga.id})
        }
        else {
            favoriteList.append(animeManga.id)
        }
        
        setFavoriteList(favoriteList)
        updateSectionModel()
    }
    
    func getPageStatus() -> PageStatus {
        return pageStatus
    }

    func updateSectionModel() {
        var newUiAnimeMangaList = apiAnimeMangaList
        
        newUiAnimeMangaList += getCustomizeAnimeManga()
        newUiAnimeMangaList = genFavoriteUiAnimeList(newUiAnimeMangaList)
        newUiAnimeMangaList = newUiAnimeMangaList.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
        
        self.tableViewDataSubject.onNext(genSectionModel(newUiAnimeMangaList))
    }
    
    func getPageType() -> PageType {
        return self.type
    }
    
    private func genAnimeUiList(_ viewObject: AnimeRespModel) -> [UiAnimeManga] {
        return viewObject.data.map { data -> UiAnimeManga in
            return .init(id: data.mal_id,
                         imageUrl: data.images.jpg.image_url ?? "noImage",
                         title: data.title,
                         rank: String(data.rank),
                         startDate: data.aired.from.components(separatedBy: "T").first ?? data.aired.from,
                         endDate: (data.aired.to ?? "nowT").components(separatedBy: "T").first ?? "now",
                         url: data.url,
                         isFavorite: false)
        }
    }
    
    private func genMangaUiList(_ viewObject: MangaRespModel) -> [UiAnimeManga] {
        return viewObject.data.map { data -> UiAnimeManga in
            return .init(id: data.mal_id,
                         imageUrl: data.images.jpg.image_url ?? "noImage",
                         title: data.title,
                         rank: String(data.rank),
                         startDate: data.published.from.components(separatedBy: "T").first ?? data.published.from,
                         endDate: (data.published.to ?? "nowT").components(separatedBy: "T").first ?? "now",
                         url: data.url,
                         isFavorite: false)
        }
    }

    private func genFavoriteUiAnimeList(_ animeMangaList: [UiAnimeManga]) -> [UiAnimeManga] {
        let favoriteList = getFavoriteList()
        
        return animeMangaList.map { animeManga -> UiAnimeManga in
            let isFavorite = favoriteList.contains(animeManga.id)
            return .init(id: animeManga.id,
                         imageUrl: animeManga.imageUrl,
                         title: animeManga.title,
                         rank: animeManga.rank,
                         startDate: animeManga.startDate,
                         endDate: animeManga.endDate,
                         url: animeManga.url,
                         isFavorite: isFavorite)
        }
    }
    
    private func genSectionModel(_ viewObject: [UiAnimeManga]) -> [SectionModel<String, UiAnimeManga>] {
        var sectionModel = [viewObject].map({ return SectionModel(model: CellType.AnimeAndManga.rawValue, items: $0)})
        
        if getPageStatus() == .LoadingMore {
            sectionModel.append(.init(model: CellType.Loading.rawValue,
                                      items: [.init(id: 0,
                                                    imageUrl: "",
                                                    title: "",
                                                    rank: "",
                                                    startDate: "",
                                                    endDate: "",
                                                    url: "",
                                                    isFavorite: false)
                                             ]))
        }
        
        return sectionModel
    }
    
    private func getFavoriteList() -> [Int] {
        
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeFavoriteList()
        }
        else {
            return UserDefaultManager.shared.getMangaFavoriteList()
        }
    }

    private func setFavoriteList(_ list: [Int]) {
        
        if type == .Anime {
            UserDefaultManager.shared.setAnimeFavoriteList(list)
        }
        else {
            UserDefaultManager.shared.setMangaFavoriteList(list)
        }
    }
    
    private func getCustomizeAnimeManga() -> [UiAnimeManga] {
        
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeCustomizeList()
        }
        else {
            return UserDefaultManager.shared.getMangaCustomizeList()
        }
    }
}

#if DEBUG
extension AnimeMangaVM {
    public func exposeGenAnimeUiList(_ viewObject: AnimeRespModel) -> [UiAnimeManga] {
        return self.genAnimeUiList(viewObject)
    }
    
    public func exposeGenMangaUiList(_ viewObject: MangaRespModel) -> [UiAnimeManga] {
        return self.genMangaUiList(viewObject)
    }
    
    public func exposeGenFavoriteUiAnimeList(_ animeMangaList: [UiAnimeManga]) -> [UiAnimeManga] {
        return self.genFavoriteUiAnimeList(animeMangaList)
    }
    
    public func exposeGenSectionModel(_ viewObject: [UiAnimeManga]) -> [SectionModel<String, UiAnimeManga>] {
        return genSectionModel(viewObject)
    }
    
    public func exposeSetPageStatus(_ status: PageStatus) {
        self.pageStatus = status
    }
    
    public func exposeSetapiAnimeMangaList(_ list: [UiAnimeManga]) {
        self.apiAnimeMangaList = list
    }
    
}
#endif
