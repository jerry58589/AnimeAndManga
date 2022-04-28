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
    private var type: PageType = .Anime
    private var noInfoAnimeFavoriteList: [Int] = []
    private var noInfoMangaFavoriteList: [Int] = []
    
    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnimeManga>]>()
    let pageTypeSubject = ReplaySubject<PageType>.create(bufferSize: 1)
    let errorHandleSubject = PublishSubject<Error>()

    init() {
        pageTypeSubject.onNext(type)
    }
    
    func setType(_ type: PageType) {
        self.type = type
        pageTypeSubject.onNext(type)

        getFavoriteList()
    }
    
    func getFavoriteList() {
        pageStatus = .LoadingMore
        
        if type == .Anime {
            noInfoAnimeFavoriteList = getUDFavoriteList()
            updateNoInfoFavoriteList()
        }
        else if type == .Manga {
            noInfoMangaFavoriteList = getUDFavoriteList()
            updateNoInfoFavoriteList()
        }
                    
        if type == .Anime && noInfoAnimeFavoriteList.count > 0 {
            callGetAnimeMangaApi(page: 1)
        }
        else if type == .Manga && noInfoMangaFavoriteList.count > 0 {
            callGetAnimeMangaApi(page: 1)
        }
        else {
            pageStatus = .NotLoadingMore
        }
        
        updateSectionModel()
    }
    
    func setFavorite(_ animeManga: UiAnimeManga) {
        var favoriteList: [Int] = getUDFavoriteList()
        
        if animeManga.isFavorite {
            favoriteList = favoriteList.filter({$0 != animeManga.id})
        }
        else {
            favoriteList.append(animeManga.id)
        }
        
        setUDFavoriteList(favoriteList)

        updateSectionModel()
    }
    
    private func callGetAnimeMangaApi(page: Int) {
        if type == .Anime {
            APIManager.shared.getAnime(page: String(page)).map { [weak self] (viewObject) -> [UiAnimeManga] in
                let animeUiList = self?.genAnimeUiList(viewObject) ?? []
                let nextPage = page + 1
                let lastPage = viewObject.pagination.last_visible_page
                
                self?.apiFavoriteAnimeList += self?.genApiFavoriteUiList(animeUiList) ?? []
                self?.updateNoInfoFavoriteList()

                if (self?.noInfoAnimeFavoriteList.count ?? 0) > 0 && lastPage >= nextPage {
                    self?.callGetAnimeMangaApi(page: nextPage)
                }
                else {
                    self?.pageStatus = .NotLoadingMore
                }
                
                return (self?.apiFavoriteAnimeList ?? [])
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.updateSectionModel()
            }, onFailure: { [weak self] (err) in
                self?.pageStatus = .Error
                self?.errorHandleSubject.onNext(err)
            }).disposed(by: disposeBag)
        }
        else {
            APIManager.shared.getManga(page: String(page)).map { [weak self] (viewObject) -> [UiAnimeManga] in
                let mangaUiList = self?.genMangaUiList(viewObject) ?? []
                let nextPage = page + 1
                let lastPage = viewObject.pagination.last_visible_page
                
                self?.apiFavoriteMangaList += self?.genApiFavoriteUiList(mangaUiList) ?? []
                self?.updateNoInfoFavoriteList()

                if (self?.noInfoMangaFavoriteList.count ?? 0) > 0 && lastPage >= nextPage {
                    self?.callGetAnimeMangaApi(page: nextPage)
                }
                else {
                    self?.pageStatus = .NotLoadingMore
                }
                
                return (self?.apiFavoriteMangaList ?? [])
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.updateSectionModel()
            }, onFailure: { [weak self] (err) in
                self?.pageStatus = .Error
                self?.errorHandleSubject.onNext(err)
            }).disposed(by: disposeBag)
        }
    }

    private func updateNoInfoFavoriteList() {
        if type == .Anime {
            noInfoAnimeFavoriteList = noInfoAnimeFavoriteList.filter { noInfoAnime in
                return !getCustomizeFavoriteUiList().contains{ $0.id == noInfoAnime}
            }
            
            noInfoAnimeFavoriteList = noInfoAnimeFavoriteList.filter { [weak self] noInfoAnime in
                return !(self?.apiFavoriteAnimeList.contains{ $0.id == noInfoAnime} ?? true)
            }
        }
        else if type == .Manga {
            noInfoMangaFavoriteList = noInfoMangaFavoriteList.filter { noInfoManga in
                return !getCustomizeFavoriteUiList().contains{ $0.id == noInfoManga}
            }
            
            noInfoMangaFavoriteList = noInfoMangaFavoriteList.filter { [weak self] noInfoManga in
                return !(self?.apiFavoriteMangaList.contains{ $0.id == noInfoManga} ?? true)
            }
        }
    }
    
    private func updateApiFavoriteList() {
        if type == .Anime {
            apiFavoriteAnimeList = apiFavoriteAnimeList.filter { apiFavoriteAnime in
                return getUDFavoriteList().contains{apiFavoriteAnime.id == $0}
            }
        }
        else if type == .Manga {
            apiFavoriteMangaList = apiFavoriteMangaList.filter { apiFavoriteManga in
                return getUDFavoriteList().contains{apiFavoriteManga.id == $0}
            }
        }
    }

    private func genAnimeUiList(_ viewObject: AnimeRespModel) -> [UiAnimeManga] {
        return viewObject.data.map { data -> UiAnimeManga in
            return .init(id: data.mal_id,
                         imageUrl: data.images.jpg.image_url ?? "noImage",
                         title: data.title,
                         rank: String(data.rank),
                         startDate: data.aired.from.components(separatedBy: "T").first ?? data.aired.from,
                         endDate: (data.aired.to ?? "now").components(separatedBy: "T").first ?? "now",
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
        
    private func genApiFavoriteUiList(_ uiAnimeMangaList: [UiAnimeManga]) -> [UiAnimeManga] {
        if type == .Anime {
            return uiAnimeMangaList.filter { uiAnimeManga in
                return noInfoAnimeFavoriteList.contains(uiAnimeManga.id)
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
                return noInfoMangaFavoriteList.contains(uiAnimeManga.id)
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
    
    private func getCustomizeFavoriteUiList() -> [UiAnimeManga] {
        return getUDCustomizeList().filter { customizeAnime in
            getUDFavoriteList().contains{ $0 == customizeAnime.id}
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
    
    private func updateSectionModel() {
        updateApiFavoriteList()
        
        if type == .Anime {
            let customizeFavoriteUiMangaList = getCustomizeFavoriteUiList()
            var resultUiAnimeList = apiFavoriteAnimeList + customizeFavoriteUiMangaList
            resultUiAnimeList = resultUiAnimeList.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
            
            tableViewDataSubject.onNext(genSectionModel(resultUiAnimeList))
        }
        else if type == .Manga {
            let customizeFavoriteUiMangaList = getCustomizeFavoriteUiList()
            var resultUiMangaList = apiFavoriteMangaList + customizeFavoriteUiMangaList
            resultUiMangaList = resultUiMangaList.sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
            
            tableViewDataSubject.onNext(genSectionModel(resultUiMangaList))
        }
    }
    
    private func getUDFavoriteList() -> [Int] {
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeFavoriteList()
        }
        else {
            return UserDefaultManager.shared.getMangaFavoriteList()
        }
    }

    private func setUDFavoriteList(_ list: [Int]) {
        if type == .Anime {
            UserDefaultManager.shared.setAnimeFavoriteList(list)
        }
        else {
            UserDefaultManager.shared.setMangaFavoriteList(list)
        }
    }
    
    private func getUDCustomizeList() -> [UiAnimeManga] {
        if type == .Anime {
            return UserDefaultManager.shared.getAnimeCustomizeList()
        }
        else {
            return UserDefaultManager.shared.getMangaCustomizeList()
        }
    }
}
