//
//  FavoritesViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import SnapKit

final class FavoritesViewConroller: UIViewController {

    // MARK: - Properties
    private var favorites: [RepositoryEntity] = []
    private let cellIdentifier = "FavoriteCell"
    private let favoriteTableView = UITableView()
    private let refreshControl = UIRefreshControl()

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Favorites repositories"
        configureFavoriteTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    // MARK: - Methods
    private func configureFavoriteTableView() {
        favoriteTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        favoriteTableView.separatorStyle = .none
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        favoriteTableView.addSubview(refreshControl)

        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    private func update() {
        favorites = CoreDataManager.shared.loadFavorites()
        favoriteTableView.reloadData()
    }
    @objc private func refresh(_ sender: UIRefreshControl) {
        update()
        sender.endRefreshing()
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewConroller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = favorites[indexPath.row].fullName
        return cell
    }
}

// MARK: - UITableViewDelegate
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

        let detailVC = DetailViewController(repository: repository, fromFavoritesList: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
