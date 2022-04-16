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

    private let tableViewDataSource = RxTableViewSectionedReloadDataSource <SectionModel<String, UiAnime>>(
        configureCell: { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeAndMangaCell") as! AnimeAndMangaCell
            cell.selectionStyle = .none
            cell.setupUI(anime: item)
            return cell
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
}
