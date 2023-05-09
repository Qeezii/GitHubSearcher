//
//  SearchViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 05.05.2023.
//

import UIKit
import SnapKit

private enum Constraints: CGFloat {
    case leading = 25
    case trailing = -25
    case verticalSpacing = 20
    case height = 35
}

final class SearchViewController: UIViewController {

    // MARK: - Properties
    private var repositories: [Repository] = []
    private let cellIdentifier: String = "SearchCell"
    private let mainTitle: String = "Search repositories"

    // MARK: - UI Elements
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.addSpaceBeforeText()
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 10
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        return textField
    }()
    private lazy var repositoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the text to search for repositories"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private lazy var searchEmptyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SearchEmpty")
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = mainTitle
        configureUIElements()
    }

    // MARK: - Methods
    private func configureUIElements() {
        configureSearchTextField()
        configureRepositoryTableView()
        configureActivityIndicatorView()
        configureHintLabel()
        configureSearchEmptyImage()
    }
    private func configureSearchTextField() {
        searchTextField.delegate = self
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
            make.height.equalTo(Constraints.height.rawValue)
        }
    }
    private func configureRepositoryTableView() {
        repositoryTableView.dataSource = self
        repositoryTableView.delegate = self
        view.addSubview(repositoryTableView)
        repositoryTableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(Constraints.verticalSpacing.rawValue)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue / 2)
            make.trailing.equalTo(searchTextField.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    private func configureActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureHintLabel() {
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(Constraints.verticalSpacing.rawValue)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
        }
    }
    private func configureSearchEmptyImage() {
        view.addSubview(searchEmptyImage)
        searchEmptyImage.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(Constraints.verticalSpacing.rawValue)
            make.centerX.equalTo(view.snp.centerX)
            make.width.height.equalTo(view.frame.width / 2)
        }
    }
    private func successReponse() {
        activityIndicatorView.stopAnimating()
        repositoryTableView.reloadData()
        guard repositories.isEmpty else { return }
        searchEmptyImage.isHidden = false
        hintLabel.isHidden = false
        hintLabel.text = "Nothing found"
    }
    private func searchRepositories() {
        guard let query = searchTextField.text else { return }
        searchEmptyImage.isHidden = true
        hintLabel.isHidden = true
        activityIndicatorView.startAnimating()
        NetworkManager.shared.fetchRepositories(query: query) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let searchResponse):
                strongSelf.repositories = searchResponse.items
                strongSelf.successReponse()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
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
