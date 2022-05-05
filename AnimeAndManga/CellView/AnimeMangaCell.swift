//
//  AnimeMangaCell.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/27.
//

import UIKit
import RxSwift


class AnimeMangaCell: UITableViewCell {
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    private var task: URLSessionDataTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        
        task?.cancel()
        task = nil
    }
    
    func updateUI(_ animeManga: UiAnimeManga) {
        rank.text = animeManga.rank
        title.text = animeManga.title
        startDate.text = animeManga.startDate
        endDate.text = animeManga.endDate
        
        if animeManga.isFavorite {
            let image = UIImage(named: "star")?.withRenderingMode(.alwaysOriginal)
            favoriteBtn.setImage(image, for: .normal)
        }
        else {
            let image = UIImage(named: "unStar")?.withRenderingMode(.alwaysOriginal)
            favoriteBtn.setImage(image, for: .normal)
        }
        
        fetchImage(urlStr: animeManga.imageUrl, completion: { [weak self] respImage in
            if let image = respImage {
                DispatchQueue.main.async { [weak self] in
                    self?.img.image = image
                }
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    self?.img.image = UIImage(named: "noImage")
                }
            }
        })
    }
    
    private func fetchImage(urlStr: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlStr) {
            task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let data = data,
                   let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
                self?.task = nil
            }
            task?.resume()
        }
        else {
            completion(nil)
        }
    }
    
}
