//
//  LoadingCell.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/18.
//

import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI() {
        loading.startAnimating()
    }
    
}
