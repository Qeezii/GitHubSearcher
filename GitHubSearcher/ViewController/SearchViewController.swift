//
//  SearchViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 05.05.2023.
//

import UIKit
import SnapKit

// убрать все let и сделать let

final class SearchViewController: UIViewController {

    // MARK: - Properties
    private var repositories: [RepositoryResponse] = []
    private var currentPage: Int = 1
    private var isShowLoadingCell: Bool = false

    // MARK: - UI Elements
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = AppConstants.Strings.SearchScreen.searchTextFieldPlaceholder

        let leftView = UIView(frame: CGRect(x: 10, y: 0, width: 7, height: textField.bounds.height))
        leftView.backgroundColor = .clear
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.contentVerticalAlignment = .center

        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 10
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        return textField
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
        configureSearchTextField()
        configureRepositoryTableView()
        configureActivityIndicatorView()
        configureHintLabel()
        configureSearchEmptyImage()
    }
    private func configureMainView() {
        view.backgroundColor = .white
        title = AppConstants.Strings.SearchScreen.title
    }
    private func configureSearchTextField() {
        searchTextField.delegate = self
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
            $0.height.equalTo(AppConstants.Constraints.height)
        }
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
            $0.top.equalTo(searchTextField.snp.bottom).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalTo(searchTextField.snp.leading)
            $0.trailing.equalTo(searchTextField.snp.trailing)
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
            $0.top.equalTo(searchTextField.snp.bottom).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureSearchEmptyImage() {
        view.addSubview(searchEmptyImageView)
        searchEmptyImageView.snp.makeConstraints {
            $0.top.equalTo(hintLabel.snp.bottom).offset(AppConstants.Constraints.verticalSpacing)
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
    private func searchRepositories() {
        guard let query = searchTextField.text else { return }
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
        guard let query = searchTextField.text else { return }
        NetworkManager.shared.fetchRepositories(query: query, page: currentPage) { [weak self] result in
            guard let self, case .success(let response) = result else { return }
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
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = searchTextField.text,
              !text.isEmpty else { return true }
        searchRepositories()
        return true
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
        let detailVC = DetailViewController(repository: repository)
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
