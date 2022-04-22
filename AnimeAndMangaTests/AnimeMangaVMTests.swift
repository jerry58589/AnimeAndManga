//
//  AnimeMangaVMTests.swift
//  AnimeAndMangaTests
//
//  Created by JerryLo on 2022/4/22.
//

import XCTest
import RxSwift
import RxDataSources
//import RxTest
@testable import AnimeAndManga

class AnimeMangaVMTests: XCTestCase {

    let vm = AnimeMangaVM.init(type: .Anime)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_genAnimeUiList() {
        let id = 123
        let imageUrl = "imageUrl"
        let title = "title"
        let rank = 321
        let startDate = "2009-04-05T00:00:00+00:00"
        let endDate = "now"
        let url = "url"
        let isFavorite = false

        let fakeRespModel: AnimeRespModel = .init(pagination: .init(last_visible_page: 0, has_next_page: false, current_page: 0, items: .init(count: 0, total: 0, per_page: 0)), data: [.init(mal_id: id, url: url, images: .init(jpg: .init(image_url: imageUrl, small_image_url: nil, medium_image_url: nil, large_image_url: nil, maximum_image_url: nil), webp: .init(image_url: nil, small_image_url: nil, medium_image_url: nil, large_image_url: nil, maximum_image_url: nil)), trailer: .init(youtube_id: nil, url: nil, embed_url: nil, images: .init(image_url: nil, small_image_url: nil, medium_image_url: nil, large_image_url: nil, maximum_image_url: nil)), title: title, title_english: nil, title_japanese: "", title_synonyms: [], type: "", source: "", episodes: nil, status: "", airing: false, aired: .init(from: startDate, to: nil, prop: .init(from: .init(day: nil, month: nil, year: nil), to: .init(day: nil, month: nil, year: nil)), string: ""), duration: "", rating: "", score: 0.0, scored_by: 0, rank: rank, popularity: 0, members: 0, favorites: 0, synopsis: "", background: nil, season: nil, year: nil, broadcast: .init(day: nil, time: nil, timezone: nil, string: nil), producers: [], licensors: [], studios: [], genres: [], explicit_genres: [], themes: [], demographics: [])])

        let fakeUiAnimeMangaList = vm.exposeGenAnimeUiList(fakeRespModel)

        XCTAssertEqual(fakeUiAnimeMangaList[0].id, id)
        XCTAssertEqual(fakeUiAnimeMangaList[0].imageUrl, imageUrl)
        XCTAssertEqual(fakeUiAnimeMangaList[0].title, title)
        XCTAssertEqual(fakeUiAnimeMangaList[0].rank, String(rank))
        XCTAssertEqual(fakeUiAnimeMangaList[0].startDate, "2009-04-05")
        XCTAssertEqual(fakeUiAnimeMangaList[0].endDate, endDate)
        XCTAssertEqual(fakeUiAnimeMangaList[0].url, url)
        XCTAssertEqual(fakeUiAnimeMangaList[0].isFavorite, isFavorite)
    }

    func test_genMangaUiList() {
        let id = 123
        let imageUrl = "imageUrl"
        let title = "title"
        let rank = 321
        let startDate = "2009-04-05T00:00:00+00:00"
        let endDate = "now"
        let url = "url"
        let isFavorite = false

        let fakeRespModel: MangaRespModel = .init(pagination: .init(last_visible_page: 0, has_next_page: false, current_page: 0, items: .init(count: 0, total: 0, per_page: 0)), data: [.init(mal_id: id, url: url, images: .init(jpg: .init(image_url: imageUrl, small_image_url: nil, medium_image_url: nil, large_image_url: nil, maximum_image_url: nil), webp: .init(image_url: nil, small_image_url: nil, medium_image_url: nil, large_image_url: nil, maximum_image_url: nil)), title: title, title_english: nil, title_japanese: "", title_synonyms: [], type: "", chapters: nil, volumes: nil, status: "", publishing: false, published: .init(from: startDate, to: nil, prop: .init(from: .init(day: nil, month: nil, year: nil), to: .init(day: nil, month: nil, year: nil)), string: ""), score: 0.0, scored: 0.0, scored_by: 0, rank: rank, popularity: 0, members: 0, favorites: 0, synopsis: "", background: nil, authors: [], serializations: [], genres: [], explicit_genres: [], themes: [], demographics: [])])

        let fakeUiAnimeMangaList = vm.exposeGenMangaUiList(fakeRespModel)

        XCTAssertEqual(fakeUiAnimeMangaList[0].id, id)
        XCTAssertEqual(fakeUiAnimeMangaList[0].imageUrl, imageUrl)
        XCTAssertEqual(fakeUiAnimeMangaList[0].title, title)
        XCTAssertEqual(fakeUiAnimeMangaList[0].rank, String(rank))
        XCTAssertEqual(fakeUiAnimeMangaList[0].startDate, "2009-04-05")
        XCTAssertEqual(fakeUiAnimeMangaList[0].endDate, endDate)
        XCTAssertEqual(fakeUiAnimeMangaList[0].url, url)
        XCTAssertEqual(fakeUiAnimeMangaList[0].isFavorite, isFavorite)
    }

    func test_genFavoriteUiAnimeList() {
        let animeFavoriteList = UserDefaultManager.shared.getAnimeFavoriteList()
        let mangaFavoriteList = UserDefaultManager.shared.getMangaFavoriteList()
        var fakeUiAnimeMangaList = [UiAnimeManga]()

        fakeUiAnimeMangaList = animeFavoriteList.map { favoriteId -> UiAnimeManga in
            return .init(id: favoriteId, imageUrl: "", title: "", rank: "", startDate: "", endDate: "", url: "", isFavorite: false)
        }

        fakeUiAnimeMangaList += mangaFavoriteList.map { favoriteId -> UiAnimeManga in
            return .init(id: favoriteId, imageUrl: "", title: "", rank: "", startDate: "", endDate: "", url: "", isFavorite: false)
        }

        let favoriteUiAnimeList = vm.exposeGenFavoriteUiAnimeList(fakeUiAnimeMangaList)

        favoriteUiAnimeList.forEach {
            if $0.isFavorite {
                XCTAssertTrue(animeFavoriteList.contains($0.id))
            }
            else {
                XCTAssertFalse(animeFavoriteList.contains($0.id))
            }
        }
    }

    func test_genSectionModel() {
        var sectionModel = [SectionModel<String, UiAnimeManga>]()
        let fakeUiAnimeMangaList = [UiAnimeManga](repeating: .init(id: 0, imageUrl: "", title: "", rank: "", startDate: "", endDate: "", url: "", isFavorite: false), count: 3)

        vm.exposeSetPageStatus(.LoadingMore)
        sectionModel = vm.exposeGenSectionModel(fakeUiAnimeMangaList)
        XCTAssertEqual(sectionModel.count, 2)

        vm.exposeSetPageStatus(.NotLoadingMore)
        sectionModel = vm.exposeGenSectionModel(fakeUiAnimeMangaList)
        XCTAssertEqual(sectionModel.count, 1)
    }

//    func test_updateSectionModel() {
//        let scheduler = TestScheduler(initialClock: 0, resolution: 1)
//        let disposeBag = DisposeBag()
//        var fakeUiAnimeMangaList = [UiAnimeManga]()
//
//        for rank in 0...10 {
//            fakeUiAnimeMangaList.append(.init(id: 0, imageUrl: "", title: "", rank: String(rank), startDate: "", endDate: "", url: "", isFavorite: false))
//        }
//
//        scheduler.scheduleAt(10) {
//            self.vm.exposeSetapiAnimeMangaList(fakeUiAnimeMangaList)
//            self.vm.updateSectionModel()
//        }
//
//        let observer = scheduler.record(vm.tableViewDataSubject.asObservable(), disposeBag: disposeBag)
//        scheduler.start()
//
//        let results = observer.events
//            .compactMap{ $0.value.element }.first?
//            .compactMap{ $0.items }.first?
//            .compactMap{ Int($0.rank)}
//
//        XCTAssertEqual(results, results?.sorted(by: {$0 < $1}))
//    }


}



