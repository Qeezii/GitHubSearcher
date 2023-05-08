//
//  MainTabBarViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchVC = SearchViewController()
        let favoriteVC = FavoritesViewConroller()

        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        favoriteVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        let tabBarList = [searchVC, favoriteVC]
        viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }
    }
}
