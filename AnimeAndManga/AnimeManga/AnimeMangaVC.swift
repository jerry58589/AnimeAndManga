//
//  AnimeMangaVC.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SafariServices

class AnimeMangaVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let addBtn = UIBarButtonItem(title: "Add", style: .done, target: self, action: nil)
    private var viewModel: AnimeMangaVM!
    private let disposeBag = DisposeBag()

    private lazy var tableViewDataSource = RxTableViewSectionedReloadDataSource <SectionModel<String, UiAnimeManga>>(
        configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
            
            if dataSource.sectionModels[indexPath.section].model == CellType.Loading.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                cell.selectionStyle = .none
                cell.updateUI()
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeMangaCell", for: indexPath) as! AnimeMangaCell
                cell.selectionStyle = .none
                cell.updateUI(item)
                cell.favoriteBtn.rx.tap.subscribe(onNext: { [weak self] in
                    self?.favoriteBtnPressed(animeManga: item)
                }).disposed(by: cell.disposeBag)
                return cell
            }
        })
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        dataBinding()
        
        viewModel.getNewPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateSectionModel()
    }
    
    func initVC(type: PageType) {
        self.viewModel = AnimeMangaVM.init(type: type)
    }
    
    private func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        
        self.navigationItem.rightBarButtonItem = addBtn
    }

    private func dataBinding() {
        viewModel.titleSubject
            .subscribe(onNext: { [weak self] (title) in
                self?.title = title
            }).disposed(by: disposeBag)
        
        viewModel.tableViewDataSubject
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)
        
        tableView?.rx.itemSelected
            .map { [weak self] (indexPath) in
                return (indexPath, self?.tableViewDataSource[indexPath])
            }
            .subscribe(onNext: { [weak self] (indexPath, animeManga) in
                
                if let url = URL(string: animeManga?.url ?? ""), UIApplication.shared.canOpenURL(url) {
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
        
        addBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.addBtnPressed()
        }).disposed(by: disposeBag)

    }
    
    private func favoriteBtnPressed(animeManga: UiAnimeManga) {
        viewModel.setFavorite(animeManga)
    }
    
    private func addBtnPressed() {
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc: AddAnimeMangaVC = storyboard.instantiateViewController(withIdentifier: "AddAnimeMangaVC") as! AddAnimeMangaVC
        vc.initVC(type: viewModel.getPageType())
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func urlErrorHandle() {
        let controller = UIAlertController(title: "Error", message: "Url can not open.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
}

extension AnimeMangaVC: UITableViewDelegate, UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                
        guard scrollView.contentSize.height > self.tableView.frame.height, viewModel.getPageStatus() == .NotLoadingMore else { return }
                        
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            viewModel.getNewPage()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
