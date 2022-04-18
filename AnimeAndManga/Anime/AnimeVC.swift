//
//  AnimeVC.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AnimeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: AnimeVM = .init()
    private let disposeBag = DisposeBag()
    private var lastPage = 1

    private lazy var tableViewDataSource = RxTableViewSectionedReloadDataSource <SectionModel<String, UiAnime>>(
        configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
            
            if dataSource.sectionModels[indexPath.section].model == CellType.Loading.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                cell.selectionStyle = .none
                cell.updateUI()
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeAndMangaCell", for: indexPath) as! AnimeAndMangaCell
                cell.selectionStyle = .none
                cell.updateUI(anime: item)
                cell.favoriteBtn.rx.tap.subscribe(onNext: { [weak self] in
                    self?.favoriteBtnPressed(anime: item)
                }).disposed(by: cell.disposeBag)
                return cell
            }
        })
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        dataBinding()
        
        viewModel.getScheduleViewObject(page: lastPage)
    }
    
    private func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
    }

    private func dataBinding() {
        viewModel.tableViewDataSubject
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected
            .map { indexPath in
                return (indexPath, self.tableViewDataSource[indexPath])
            }
            .subscribe(onNext: { (indexPath, anime) in
                if let url = URL(string: anime.url) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            })
            .disposed(by: disposeBag)

    }
    
    private func favoriteBtnPressed(anime: UiAnime) {
        viewModel.setFavorite(anime: anime)
    }
}

extension AnimeVC: UITableViewDelegate, UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                
        guard scrollView.contentSize.height > self.tableView.frame.height, viewModel.getPageStatus() == .NotLoadingMore else { return }
                        
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            lastPage += 1
            viewModel.getScheduleViewObject(page: lastPage)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
