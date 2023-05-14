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
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leading)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailing)
            $0.height.equalTo(AppConstants.Constraints.height)
        }
    }
    private func configureRepositoryTableView() {
        repositoryTableView.dataSource = self
        repositoryTableView.delegate = self
        repositoryTableView.register(UITableViewCell.self,
                                     forCellReuseIdentifier: AppConstants.Strings.SearchScreen.cellIdentifier)
        repositoryTableView.addGestureRecognizer(swipeDownRecognizer)
        view.addSubview(repositoryTableView)
        repositoryTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
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
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leading)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailing)
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
    private func successReponse() {
        activityIndicatorView.stopAnimating()
        repositoryTableView.reloadData()
        guard repositories.isEmpty else { return }
        searchEmptyImageView.isHidden = false
        hintLabel.isHidden = false
        hintLabel.text = AppConstants.Strings.SearchScreen.hintLabelTextNothingFound
    }
    private func searchRepositories() {
        guard let query = searchTextField.text else { return }
        searchEmptyImageView.isHidden = true
        hintLabel.isHidden = true
        activityIndicatorView.startAnimating()
        NetworkManager.shared.fetchRepositories(query: query) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let searchResponse):
                DispatchQueue.main.async {
                    strongSelf.repositories = searchResponse.items
                    strongSelf.successReponse()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
                                                 for: indexPath)
        cell.textLabel?.text = repositories[indexPath.row].fullName
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let detailVC = DetailViewController(repository: repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
