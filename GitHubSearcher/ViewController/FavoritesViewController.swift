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

    // MARK: - UI Elements
    private let favoriteTableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        return tableView
    }()
    private let emptyFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = AppConstants.Strings.FavoritesScreen.emptyFavoritesLabelText
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private let refreshControl = UIRefreshControl()

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    // MARK: - Methods
    private func configureUIElements() {
        congifureMainView()
        configureFavoriteTableView()
        configureEmptyFavoritesLabel()
    }
    private func congifureMainView() {
        view.backgroundColor = .white
        title = AppConstants.Strings.FavoritesScreen.title
    }
    private func configureFavoriteTableView() {
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self
        favoriteTableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: AppConstants.Strings.FavoritesScreen.cellIdentifier)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        favoriteTableView.addSubview(refreshControl)
        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    private func configureEmptyFavoritesLabel() {
        view.addSubview(emptyFavoritesLabel)
        emptyFavoritesLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leading)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailing)
            $0.centerY.equalTo(view.snp.centerY)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.Strings.FavoritesScreen.cellIdentifier,
                                                 for: indexPath)
        cell.textLabel?.text = favorites[indexPath.row].fullName
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewConroller: UITableViewDelegate {
    private func getRepositoryFromCoreData(_ favRepository: RepositoryEntity) -> RepositoryResponse {
        RepositoryResponse(
            id: Int(favRepository.repositoryID),
            fullName: favRepository.fullName,
            owner: OwnerResponse(
                login: favRepository.ownerLogin,
                name: favRepository.ownerName,
                email: favRepository.ownerEmail),
            description: favRepository.descrip)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favRepository = favorites[indexPath.row]
        let repository = getRepositoryFromCoreData(favRepository)

        let detailVC = DetailViewController(repository: repository, fromFavoritesList: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
