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
        
//        let url = URL(string: anime.image)
//        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//        if let xx = Dat
        
        img.image = UIImage(data: anime.imageData)
        
    }
    
}
