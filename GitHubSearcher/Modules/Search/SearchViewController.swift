//
//  SearchViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 05.05.2023.
//

import UIKit
import SnapKit


final class SearchViewController: UIViewController {

    // MARK: - Properties
    private var repositories: [RepositoryResponse] = []
    private var searchText: String = ""
    private var currentPage: Int = 1
    private var isShowLoadingCell: Bool = false

    // MARK: - UI Elements
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = AppConstants.Strings.SearchScreen.searchTextFieldPlaceholder
        return searchController
    }()
    private let repositoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets.zero
        return tableView
    }()
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = AppConstants.Strings.SearchScreen.hintLabelTextDefault
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private let searchEmptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AppConstants.Strings.SearchScreen.searchEmptyImageViewImageName)
        imageView.isHidden = true
        return imageView
    }()
    private lazy var swipeDownRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.addTarget(self, action: #selector(hideKeyboardOnSwipeDown))
        recognizer.delegate = self
        recognizer.direction = UISwipeGestureRecognizer.Direction.down
        return recognizer
    }()
    private let spinnerActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIElements()
    }

    // MARK: - Methods
    private func configureUIElements() {
        configureMainView()
        configureRepositoryTableView()
        configureActivityIndicatorView()
        configureHintLabel()
        configureSearchEmptyImage()
    }
    private func configureMainView() {
        view.backgroundColor = .white
        title = AppConstants.Strings.SearchScreen.title
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    private func configureRepositoryTableView() {
        repositoryTableView.dataSource = self
        repositoryTableView.delegate = self
        repositoryTableView.register(RepositoryTableViewCell.self,
                                     forCellReuseIdentifier: AppConstants.Strings.SearchScreen.cellIdentifier)
        repositoryTableView.tableFooterView = spinnerActivityIndicatorView
        repositoryTableView.tableFooterView?.isHidden = true
        spinnerActivityIndicatorView.frame = CGRect(x: 0, y: 0, width: repositoryTableView.bounds.width, height: 44)
        repositoryTableView.addGestureRecognizer(swipeDownRecognizer)
        view.addSubview(repositoryTableView)
        repositoryTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(AppConstants.Constraints.verticalSpacingMiddle)
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    private func configureActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    private func configureHintLabel() {
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureSearchEmptyImage() {
        view.addSubview(searchEmptyImageView)
        searchEmptyImageView.snp.makeConstraints {
            $0.top.equalTo(hintLabel.snp.bottom).offset(AppConstants.Constraints.verticalSpacingMiddle)
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.height.equalTo(view.snp.width).dividedBy(2)
        }
    }
    private func successResponse() {
        activityIndicatorView.stopAnimating()
        repositoryTableView.reloadData()
        guard repositories.isEmpty else { return }
        searchEmptyImageView.isHidden = false
        hintLabel.isHidden = false
        hintLabel.text = AppConstants.Strings.SearchScreen.hintLabelTextNothingFound
    }
    private func errorResponse(message: String) {
        activityIndicatorView.stopAnimating()
        showErrorAlertWith(message)
    }
    private func searchRepositories(query: String) {
        searchEmptyImageView.isHidden = true
        hintLabel.isHidden = true
        activityIndicatorView.startAnimating()
        NetworkManager.shared.fetchRepositories(query: query, page: currentPage) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let searchResponse):
                DispatchQueue.main.async {
                    self.repositories = searchResponse.items
                    self.successResponse()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorResponse(message: error.localizedDescription)
                }
            }
        }
    }
    private func loadMoreRepositories() {
        guard !isShowLoadingCell,
              currentPage < 10 else { return }
        repositoryTableView.tableFooterView?.isHidden = false
        isShowLoadingCell.toggle()
        currentPage += 1
        NetworkManager.shared.fetchRepositories(query: searchText, page: currentPage) { [weak self] result in
            guard let self, case .success(let response) = result else {
                DispatchQueue.main.async {
                    self?.isShowLoadingCell.toggle()
                    self?.repositoryTableView.tableFooterView?.isHidden = true
                }
                return
            }
            let oldCount = self.repositories.count
            DispatchQueue.main.async {
                self.repositories.append(contentsOf: response.items)
                let indexPaths = (oldCount ..< self.repositories.count).map { IndexPath(row: $0, section: 0) }
                self.repositoryTableView.insertRows(at: indexPaths, with: .automatic)
                self.isShowLoadingCell.toggle()
                self.repositoryTableView.tableFooterView?.isHidden = true
            }
        }
    }
    private func showErrorAlertWith(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @objc private func hideKeyboardOnSwipeDown() {
        searchController.searchBar.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.Strings.SearchScreen.cellIdentifier,
                                                 for: indexPath) as? RepositoryTableViewCell
        switch cell {
        case .none:
            return UITableViewCell()
        case .some(let cellUnwrap):
            let fullName = repositories[indexPath.row].fullName
            cellUnwrap.setupFullName(fullName)
            return cellUnwrap
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let detailVC = DetailViewController()
        detailVC.getRepository(repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == repositories.count - 1 else { return }
        loadMoreRepositories()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchText = query
        currentPage = 1
        searchRepositories(query: searchText.trimmingCharacters(in: .whitespaces))
    }
}
