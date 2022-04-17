//
//  AnimeAndMangaCell.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import UIKit
import RxSwift

class AnimeAndMangaCell: UITableViewCell {

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
    
    func setupUI(anime: UiAnime) {
        rank.text = anime.rank
        title.text = anime.title
        startDate.text = anime.startDate
        endDate.text = anime.endDate
        
        if anime.isFavorite {
            let image = UIImage(named: "star")?.withRenderingMode(.alwaysOriginal)
            favoriteBtn.setImage(image, for: .normal)
        }
        else {
            let image = UIImage(named: "unStar")?.withRenderingMode(.alwaysOriginal)
            favoriteBtn.setImage(image, for: .normal)
        }
        
        let url = URL(string: anime.image)

        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.img.image = UIImage(data: data!)
            }
        }
    }
    
}
