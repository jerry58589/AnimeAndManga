//
//  AddAnimeMangaVC.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/18.
//

import UIKit
import RxSwift
import RxCocoa

class AddAnimeMangaVC: UIViewController {

    @IBOutlet weak var rankText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var startDateText: UITextField!
    @IBOutlet weak var endDateText: UITextField!
    @IBOutlet weak var imgUrlText: UITextField!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var saveBtn: UIButton!
    
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let formatter = DateFormatter()
    private var disposeBag = DisposeBag()
    private var viewModel: AddAnimeMangaVM?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        dataBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    deinit {
        print("AddAnimeMangaVC deinit")
    }
    
    func initVC(type: PageType) {
        self.viewModel = AddAnimeMangaVM.init(type: type)
    }
    
    private func setupUI() {
        startDatePicker.datePickerMode = .date
        startDatePicker.date = Date()
        endDatePicker.datePickerMode = .date
        endDatePicker.date = Date()

        formatter.dateFormat = "yyyy-MM-dd"

        startDateText.inputView = startDatePicker
        endDateText.inputView = endDatePicker
    }
    
    private func dataBinding() {
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.dismissKeyboard()
        })
        .disposed(by: disposeBag)
        
        self.view.addGestureRecognizer(tap)
        
        viewModel?.titleSubject
            .subscribe(onNext: { [weak self] (title) in
                self?.title = title
            }).disposed(by: disposeBag)
        
        startDatePicker.rx.date
            .map { [weak self] _ in
                self?.formatter.string(from: (self?.startDatePicker.date) ?? Date())
            }
            .bind(to: startDateText.rx.text)
            .disposed(by: disposeBag)
        
        endDatePicker.rx.date
            .map { [weak self] _ in
                self?.formatter.string(from: (self?.startDatePicker.date) ?? Date())
            }
            .bind(to: endDateText.rx.text)
            .disposed(by: disposeBag)

        titleText.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        imgUrlText.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        urlText.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        saveBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.saveBtnPressed()
            }).disposed(by: disposeBag)
        
        viewModel?.setAnimeMangaSubject
            .subscribe(onNext: { [weak self] _ in
                self?.back()
            }).disposed(by: disposeBag)
    }
    

    private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func saveBtnPressed() {
        let randomId = Int.random(in: 10000000...99999999)
        
        let newAnimeManga = UiAnimeManga(id: randomId,
                               imageUrl: imgUrlText.text ?? "",
                               title: titleText.text ?? "",
                               rank: rankText.text ?? "",
                               startDate: startDateText.text ?? "",
                               endDate: endDateText.text ?? "",
                               url: urlText.text ?? "",
                               isFavorite: favoriteSwitch.isOn)
                
        viewModel?.setAnimeManga(newAnimeManga)
    }
    
    private func back() {
        self.navigationController?.popViewController(animated: true)
    }
}
