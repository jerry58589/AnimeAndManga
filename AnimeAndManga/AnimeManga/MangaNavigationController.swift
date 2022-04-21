//
//  MangaNavigationController.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/21.
//

import UIKit

class MangaNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc: AnimeMangaVC = storyboard.instantiateViewController(withIdentifier: "AnimeMangaVC") as! AnimeMangaVC
        vc.initVC(type: .Manga)
        
        self.setViewControllers([vc], animated: false)
    }
}
