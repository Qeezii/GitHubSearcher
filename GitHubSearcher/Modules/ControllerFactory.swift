//
//  ControllerFactory.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 16.05.2023.
//

import UIKit

protocol ControllerFactoryProtocol {
    func makeSearchViewController() -> UIViewController
    func makeFavoritesViewController() -> UIViewController
    func makeMainTabBarController() -> UIViewController
}

final class ControllerFactory: ControllerFactoryProtocol {

    func makeSearchViewController() -> UIViewController {
        SearchViewController()
    }

    func makeFavoritesViewController() -> UIViewController {
        FavoritesViewConroller()
    }

    func makeMainTabBarController() -> UIViewController {
        let tabBarController = UITabBarController()
        let searchVC = makeSearchViewController()
        let favoritesVC = makeFavoritesViewController()

        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        favoritesVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        let tabBarList = [searchVC, favoritesVC]
        tabBarController.viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }

        return tabBarController
    }
}
