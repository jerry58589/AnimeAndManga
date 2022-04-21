//
//  AnimeNavigationController.swift
//  AnimeAndManga
//
//  Created by JerryLo on 2022/4/21.
//

import UIKit

class AnimeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc: AnimeVC = storyboard.instantiateViewController(withIdentifier: "AnimeVC") as! AnimeVC
        vc.initVC(type: .Anime)
        
        self.setViewControllers([vc], animated: false)
    }

}
