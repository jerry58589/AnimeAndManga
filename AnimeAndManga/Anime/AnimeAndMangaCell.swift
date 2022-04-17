//
//  AnimeAndMangaCell.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/16.
//

import UIKit

class AnimeAndMangaCell: UITableViewCell {

    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(anime: UiAnime) {
        rank.text = anime.rank
        title.text = anime.title
        startDate.text = anime.startDate
        endDate.text = anime.endDate
        
        let url = URL(string: anime.image)

        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.img.image = UIImage(data: data!)
            }
        }        
    }
    
}
