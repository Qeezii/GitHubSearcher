//
//  FavoritesViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import SnapKit

class FavoritesViewConroller: UIViewController {

    private var favorites: [RepositoryEntity] = []
    private let favoriteTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Favorites repositories"
        favorites = CoreDataManager.shared.loadFavorites()
        configureFavoriteTableView()
    }

    private func configureFavoriteTableView() {
        favoriteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "favorite")
        favoriteTableView.separatorStyle = .none
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self

        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension FavoritesViewConroller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favorite", for: indexPath)
        cell.textLabel?.text = favorites[indexPath.row].fullName
        return cell
    }
}

extension FavoritesViewConroller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favRepository = favorites[indexPath.row]
        let repository = Repository(
            id: Int(favRepository.repositoryID),
            fullName: favRepository.fullName,
            owner: Owner(
                login: favRepository.ownerLogin,
                name: favRepository.ownerName,
                email: favRepository.ownerEmail),
            description: favRepository.descrip)

        let detailVC = DetailViewController(repository: repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}