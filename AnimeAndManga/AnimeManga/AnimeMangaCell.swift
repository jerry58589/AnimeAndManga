//
//  AnimeMangaCell.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
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
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
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
        
        DispatchQueue.global().async {
            if let url = URL(string: animeManga.imageUrl), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.img.image = UIImage(data: data)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.img.image = UIImage(named: "noImage")
                }
            }
        }
    }
    
}
