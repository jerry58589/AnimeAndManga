//
//  FavoriteListVM.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/27.
//

import Foundation
import RxSwift
import RxDataSources

class FavoriteListVM {
    private let disposeBag = DisposeBag()
    private var apiFavoriteAnimeList = [UiAnimeManga]()
    private var apiFavoriteMangaList = [UiAnimeManga]()
    private var pageStatus: PageStatus = .NotLoadingMore
    private(set) var pageType: PageType = .Anime
    private var noInfoAnimeFavoriteList: [UiFavorite] = []
    private var noInfoMangaFavoriteList: [UiFavorite] = []
    private var needGetAnimePages = [Int]()
    private var needGetMangaPages = [Int]()
    private let retryMaxCount = 5
    private var retryCount = 0

    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnimeManga>]>()
    let pageTypeSubject = ReplaySubject<PageType>.create(bufferSize: 1)
    let errorHandleSubject = PublishSubject<Error>()

    init() {
        pageTypeSubject.onNext(pageType)
    }
    
    func setType(_ type: PageType) {
        self.pageType = type
        pageTypeSubject.onNext(type)

        getFavoriteList(type: type)
    }
    
    func getFavoriteList(type: PageType) {
        pageStatus = .LoadingMore
        
        if type == .Anime {
            noInfoAnimeFavoriteList = getUDFavoriteList(type: type)
            updateNoInfoFavoriteList(type: type)
            genApiPageList(type: type)
        }
        else if type == .Manga {
            noInfoMangaFavoriteList = getUDFavoriteList(type: type)
            updateNoInfoFavoriteList(type: type)
            genApiPageList(type: type)
        }
                    
        if type == .Anime && needGetAnimePages.count > 0 {
            callGetAnimeMangaApi(type: type, page: needGetAnimePages.first ?? 1)
        }
        else if type == .Manga && needGetMangaPages.count > 0 {
            callGetAnimeMangaApi(type: type, page: needGetMangaPages.first ?? 1)
        }
        else {
            pageStatus = .NotLoadingMore
        }
        
        updateSectionModel(type: pageType)
    }
    
    func setFavorite(_ animeManga: UiAnimeManga) {
        var favoriteList: [UiFavorite] = getUDFavoriteList(type: pageType)
        
        if animeManga.isFavorite {
            favoriteList = favoriteList.filter({$0.id != animeManga.id})
        }
        else {
            favoriteList.append(.init(id: animeManga.id, rank: animeManga.rank))
        }
        
        setUDFavoriteList(favoriteList)

        updateSectionModel(type: pageType)
    }
    
    private func callGetAnimeMangaApi(type: PageType, page: Int) {
        if type == .Anime && pageType == .Anime {
            print("FavoriteListVM get Anime:", page)
            APIManager.shared.getAnime(page: String(page)).map { [weak self] (viewObject) -> [UiAnimeManga] in
                let animeUiList = self?.genAnimeUiList(viewObject) ?? []
                let hasNextPage = viewObject.pagination.has_next_page
                
                self?.needGetAnimePages.removeFirst()
                let nextPage = self?.needGetAnimePages.first ?? 0
                
                self?.apiFavoriteAnimeList += self?.genApiFavoriteUiList(type: type, animeUiList) ?? []
                self?.updateNoInfoFavoriteList(type: type)

                if nextPage > 0 && hasNextPage {
                    self?.callGetAnimeMangaApi(type: type, page: nextPage)
                }
                else {
                    self?.pageStatus = .NotLoadingMore
                    print("FavoriteListVM get Anime is finish!!")
                }
                
                return (self?.apiFavoriteAnimeList ?? [])
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.retryCount = 0
                self?.updateSectionModel(type: self?.pageType ?? .Anime)
            }, onFailure: { [weak self] (err) in
                if (self?.retryCount ?? 0) < (self?.retryMaxCount ?? 0) {
                    self?.retryCount += 1
                    self?.callGetAnimeMangaApi(type: type, page: page)
                    print("FavoriteListVM get Anime retry", self?.retryCount ?? 0)
                }
                else {
                    self?.pageStatus = .Error
                    self?.errorHandleSubject.onNext(err)
                    print("FavoriteListVM get Anime is error:", err.localizedDescription)
                }
            }).disposed(by: disposeBag)
        }
        else if type == .Manga && pageType == .Manga {
            print("FavoriteListVM get Manga:", page)
            APIManager.shared.getManga(page: String(page)).map { [weak self] (viewObject) -> [UiAnimeManga] in
                let mangaUiList = self?.genMangaUiList(viewObject) ?? []
                let hasNextPage = viewObject.pagination.has_next_page
                
                self?.needGetMangaPages.removeFirst()
                let nextPage = self?.needGetMangaPages.first ?? 0

                self?.apiFavoriteMangaList += self?.genApiFavoriteUiList(type: type, mangaUiList) ?? []
                self?.updateNoInfoFavoriteList(type: type)

                if nextPage > 0 && hasNextPage {
                    self?.callGetAnimeMangaApi(type: type, page: nextPage)
                }
                else {
                    self?.pageStatus = .NotLoadingMore
                    print("FavoriteListVM get Manga is finish!!")
                }
                
                return (self?.apiFavoriteMangaList ?? [])
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.retryCount = 0
                self?.updateSectionModel(type: self?.pageType ?? .Manga)
            }, onFailure: { [weak self] (err) in                
                if (self?.retryCount ?? 0) < (self?.retryMaxCount ?? 0) {
                    self?.retryCount += 1
                    self?.callGetAnimeMangaApi(type: type, page: page)
                    print("FavoriteListVM get Manga retry", self?.retryCount ?? 0)
                }
                else {
                    self?.pageStatus = .Error
                    self?.errorHandleSubject.onNext(err)
                    print("FavoriteListVM get Manga is error:", err.localizedDescription)
                }

            }).disposed(by: disposeBag)
        }
        else {
            print("FavoriteListVM get api stop type:", type)
        }
    }

    private func updateNoInfoFavoriteList(type: PageType) {
        if type == .Anime {
            noInfoAnimeFavoriteList = noInfoAnimeFavoriteList.filter { noInfoAnime in
                return !getCustomizeFavoriteUiList(type: type).contains{ $0.id == noInfoAnime.id}
            }
            
            noInfoAnimeFavoriteList = noInfoAnimeFavoriteList.filter { [weak self] noInfoAnime in
                return !(self?.apiFavoriteAnimeList.contains{ $0.id == noInfoAnime.id} ?? true)
            }
        }
        else if type == .Manga {
            noInfoMangaFavoriteList = noInfoMangaFavoriteList.filter { noInfoManga in
                return !getCustomizeFavoriteUiList(type: type).contains{ $0.id == noInfoManga.id}
            }
            
            noInfoMangaFavoriteList = noInfoMangaFavoriteList.filter { [weak self] noInfoManga in
                return !(self?.apiFavoriteMangaList.contains{ $0.id == noInfoManga.id} ?? true)
            }
        }
    }
    
    private func genApiPageList(type: PageType){
        
        var noInfoFavoriteList = [UiFavorite]()
        
        if type == .Anime {
            noInfoFavoriteList = noInfoAnimeFavoriteList
        }
        else if type == .Manga {
            noInfoFavoriteList = noInfoMangaFavoriteList
        }
        
        let pageList = noInfoFavoriteList.map { uiFavorite -> [Int] in
                                    let rank = Int(uiFavorite.rank) ?? 1
                                    let page = Int(rank/25) + 1
                                    
                                    if page > 1 {
                                        return [page - 1, page, page + 1]
                                    }
                                    else {
                                        return [page, page + 1]
                                    }
                                }.flatMap{$0}
            
        var resultPageList = [Int]()
        
        pageList.forEach {
            if !(resultPageList.contains($0)) {
                resultPageList.append($0)
            }
        }
        
        resultPageList = resultPageList.sorted(by: {$0 < $1})
        
        if type == .Anime {
            needGetAnimePages = resultPageList
        }
        else if type == .Manga {
            needGetMangaPages = resultPageList
        }
    }
    
    
    private func updateApiFavoriteList(type: PageType) {
        if type == .Anime {
            apiFavoriteAnimeList = apiFavoriteAnimeList.filter { apiFavoriteAnime in
                return getUDFavoriteList(type: type).contains{apiFavoriteAnime.id == $0.id}
            }
        }
        else if type == .Manga {
            apiFavoriteMangaList = apiFavoriteMangaList.filter { apiFavoriteManga in
                return getUDFavoriteList(type: type).contains{apiFavoriteManga.id == $0.id}
            }
        }
    }

    private func genAnimeUiList(_ viewObject: AnimeRespModel) -> [UiAnimeManga] {
        return viewObject.data.map { data -> UiAnimeManga in
            return .init(id: data.mal_id,
                         imageUrl: data.images.jpg.image_url ?? "noImage",
                         title: data.title,
                         rank: String(data.rank),
                         startDate: (data.aired?.from ?? "nil").components(separatedBy: "T").first ?? "nil",
                         endDate: (data.aired?.to ?? "now").components(separatedBy: "T").first ?? "now",
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
                         startDate: (data.published?.from ?? "nil").components(separatedBy: "T").first ?? "nil",
                         endDate: (data.published?.to ?? "now").components(separatedBy: "T").first ?? "now",
                         url: data.url,
                         isFavorite: false)
        }
    }
        
    private func genApiFavoriteUiList(type: PageType, _ uiAnimeMangaList: [UiAnimeManga]) -> [UiAnimeManga] {
        if type == .Anime {
            return uiAnimeMangaList.filter { uiAnimeManga in
                return noInfoAnimeFavoriteList.contains{$0.id == uiAnimeManga.id}
            }.map { uiAnimeManga -> UiAnimeManga in
                return .init(id: uiAnimeManga.id,
                             imageUrl: uiAnimeManga.imageUrl,
                             title: uiAnimeManga.title,
                             rank: uiAnimeManga.rank,
                             startDate: uiAnimeManga.startDate,
                             endDate: uiAnimeManga.endDate,
                             url: uiAnimeManga.url,
                             isFavorite: true)
            }
        }
        else {
            return uiAnimeMangaList.filter { uiAnimeManga in
                return noInfoMangaFavoriteList.contains{$0.id == uiAnimeManga.id}
            }.map { uiAnimeManga -> UiAnimeManga in
                return .init(id: uiAnimeManga.id,
                             imageUrl: uiAnimeManga.imageUrl,
                             title: uiAnimeManga.title,
                             rank: uiAnimeManga.rank,
                             startDate: uiAnimeManga.startDate,
                             endDate: uiAnimeManga.endDate,
                             url: uiAnimeManga.url,
                             isFavorite: true)
            }
        }
        
    }
    
    private func getCustomizeFavoriteUiList(type: PageType) -> [UiAnimeManga] {
        return getUDCustomizeList(type: type).filter { customizeAnime in
            getUDFavoriteList(type: type).contains{ $0.id == customizeAnime.id}
        }.map { anime -> UiAnimeManga in
            return .init(id: anime.id,
                         imageUrl: anime.imageUrl,
                         title: anime.title,
                         rank: anime.rank,
                         startDate: anime.startDate,
                         endDate: anime.endDate,
                         url: anime.url,
                         isFavorite: true)
        }
    }
        
    private func genSectionModel(_ viewObject: [UiAnimeManga]) -> [SectionModel<String, UiAnimeManga>] {
        var sectionModel = [viewObject].map({ return SectionModel(model: CellType.AnimeAndManga.rawValue, items: $0)})
        
        if pageStatus == .LoadingMore {
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
    
    private func updateSectionModel(type: PageType) {
        updateApiFavoriteList(type: type)
        
        if type == .Anime {
            let customizeFavoriteUiMangaList = getCustomizeFavoriteUiList(type: type)
            var resultUiAnimeList = apiFavoriteAnimeList + customizeFavoriteUiMangaList
            resultUiAnimeList = resultUiAnimeList.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
            
            tableViewDataSubject.onNext(genSectionModel(resultUiAnimeList))
        }
        else if type == .Manga {
            let customizeFavoriteUiMangaList = getCustomizeFavoriteUiList(type: type)
            var resultUiMangaList = apiFavoriteMangaList + customizeFavoriteUiMangaList
            resultUiMangaList = resultUiMangaList.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
            
            tableViewDataSubject.onNext(genSectionModel(resultUiMangaList))
        }
    }
    
    private func getUDFavoriteList(type: PageType) -> [UiFavorite] {
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeFavoriteList()
        }
        else {
            return UserDefaultManager.shared.getMangaFavoriteList()
        }
    }

    private func setUDFavoriteList(_ list: [UiFavorite]) {
        if pageType == .Anime {
            UserDefaultManager.shared.setAnimeFavoriteList(list)
        }
        else {
            UserDefaultManager.shared.setMangaFavoriteList(list)
        }
    }
    
    private func getUDCustomizeList(type: PageType) -> [UiAnimeManga] {
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeCustomizeList()
        }
        else {
            return UserDefaultManager.shared.getMangaCustomizeList()
        }
    }
}
