//
//  FavoritesViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import SnapKit

private enum Constraints: CGFloat {
    case leading = 25
    case trailing = -25
}

final class FavoritesViewConroller: UIViewController {

    // MARK: - Properties
    private var favorites: [RepositoryEntity] = []
    private let cellIdentifier = "FavoriteCell"

    // MARK: - UI Elements
    private lazy var favoriteTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    private lazy var emptyFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing has been added to favorites"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private let refreshControl = UIRefreshControl()

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Favorites repositories"
        configureUIElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    // MARK: - Methods
    private func configureUIElements() {
        configureFavoriteTableView()
        configureEmptyFavoritesLabel()
    }
    private func configureFavoriteTableView() {
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
    private func configureEmptyFavoritesLabel() {
        view.addSubview(emptyFavoritesLabel)
        emptyFavoritesLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
            make.centerY.equalTo(view.snp.centerY)
        }
    }
    private func update() {
        favorites = CoreDataManager.shared.loadFavorites()
        emptyFavoritesLabel.isHidden = favorites.isEmpty ? false : true
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
