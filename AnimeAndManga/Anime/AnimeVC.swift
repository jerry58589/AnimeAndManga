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
import SafariServices

class AnimeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let addBtn = UIBarButtonItem(title: "Add", style: .done, target: self, action: nil)
    
    private let viewModel: AnimeVM = .init()
    private var disposeBag = DisposeBag()
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
        
        viewModel.getNewPage(lastPage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateSectionModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.disposeBag = DisposeBag()
    }
    
    private func setupUI() {
        self.title = "Anime"
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        
        self.navigationItem.rightBarButtonItem = addBtn
    }

    private func dataBinding() {
        viewModel.tableViewDataSubject
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { indexPath in
                return (indexPath, self.tableViewDataSource[indexPath])
            }
            .subscribe(onNext: { [weak self] (indexPath, anime) in
                
                if let url = URL(string: anime.url) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    
                    let vc = SFSafariViewController(url: url, configuration: config)
                    self?.present(vc, animated: true)
                }
                else {
                    self?.urlErrorHandle()
                }
            })
            .disposed(by: disposeBag)
        
        addBtn.rx.tap.subscribe(onNext: {
            self.addBtnPressed()
        }).disposed(by: disposeBag)

    }
    
    private func favoriteBtnPressed(anime: UiAnime) {
        viewModel.setFavorite(anime)
    }
    
    private func addBtnPressed() {
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc: AddAnimeAndMangaVC = storyboard.instantiateViewController(withIdentifier: "AddAnimeAndMangaVC") as! AddAnimeAndMangaVC
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func urlErrorHandle() {
        let controller = UIAlertController(title: "Error", message: "Url can not open.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
}

extension AnimeVC: UITableViewDelegate, UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                
        guard scrollView.contentSize.height > self.tableView.frame.height, viewModel.getPageStatus() == .NotLoadingMore else { return }
                        
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            lastPage += 1
            viewModel.getNewPage(lastPage)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
