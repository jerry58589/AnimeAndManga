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

class AnimeVM {
    private let disposeBag = DisposeBag()
    private var allSectionModel = [SectionModel<String, UiAnime>]()
    private var pageStatus: PageStatus = .NotLoadingMore
    let tableViewDataSubject = PublishSubject<[SectionModel<String, UiAnime>]>()

    func getScheduleViewObject(page: Int) {
        pageStatus = .LoadingMore
        APIManager.shared.getAnime(page: String(page)).map { [weak self] viewObject -> [UiAnime] in
            return self?.genUiAnimeList(viewObject: viewObject) ?? []
        }
        .subscribe(onSuccess: { [weak self] viewObject in
            self?.tableViewDataSubject.onNext((self?.genSectionModel(viewObject: viewObject))!)
            self?.pageStatus = .NotLoadingMore
        }, onFailure: { [weak self] err in
            print(err)
            self?.tableViewDataSubject.onError(err)
        }).disposed(by: disposeBag)
    }

    
    private func genUiAnimeList(viewObject: AnimeRespModel) -> [UiAnime] {
        
        return viewObject.data.map { data -> UiAnime in
            return .init(image: data.images.jpg.image_url ?? "noImage", title: data.title, rank: String(data.rank), startDate: data.aired.from.components(separatedBy: "T").first ?? data.aired.from, endDate: (data.aired.to ?? "nowT").components(separatedBy: "T").first ?? "now")
        }
        .sorted(by: {Int($0.rank) ?? 0 < Int($1.rank) ?? 0})
        
    }
    
    private func genSectionModel(viewObject: [UiAnime]) -> [SectionModel<String, UiAnime>] {
        let sectionModel = [viewObject].map({ return SectionModel(model: "", items: $0)})
        allSectionModel += sectionModel
        return allSectionModel
    }
    
    func getPageStatus() -> PageStatus {
        return pageStatus
    }

}
