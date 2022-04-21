//
//  MangaVC.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SafariServices

class MangaVC: UIViewController {

    private let viewModel: MangaVM = .init()
    private var disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = .blue
        
//        APIManager.shared.getAnime(page: String(page)).map { [weak self] viewObject -> [UiAnime] in
//            return self?.genUiAnimeList(viewObject) ?? []
//        }
//        .subscribe(onSuccess: { [weak self] newUiAnimeList in
//            self?.pageStatus = .NotLoadingMore
//            self?.apiAnimeList += newUiAnimeList
//            self?.updateSectionModel()
//        }, onFailure: { [weak self] err in
//            print(err)
//            self?.tableViewDataSubject.onError(err)
//        }).disposed(by: disposeBag)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getNewPage(1)
    }
    
}
