//
//  ViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 05.05.2023.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController {

    private var repositories: [Repository] = []

    private let searchTextField = UITextField()
    private let repositoryTableView = UITableView()
    private let activityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUIElements()
    }

    private func configureUIElements() {
        configureSearchTextField()
        configureRepositoryTableView()
        configureActivityIndicatorView()
    }
    private func configureSearchTextField() {
        searchTextField.placeholder = "  Enter text..."
        searchTextField.delegate = self
        searchTextField.layer.borderWidth = 1.5
        searchTextField.layer.borderColor = UIColor.systemGray.cgColor
        searchTextField.layer.cornerRadius = 10

        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.addAction(UIAction(handler: { _ in
            let _ = self.textFieldShouldReturn(self.searchTextField)
        }), for: .touchUpInside)
        searchTextField.rightView = searchButton
        searchTextField.rightViewMode = .whileEditing

        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(35)
        }
    }
    private func configureRepositoryTableView() {
        repositoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        repositoryTableView.dataSource = self
        repositoryTableView.delegate = self

        view.addSubview(repositoryTableView)
        repositoryTableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(25)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    private func configureActivityIndicatorView() {
        activityIndicatorView.style = .large
        activityIndicatorView.hidesWhenStopped = true

        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func searchRepository() {
        activityIndicatorView.startAnimating()
        guard let query = searchTextField.text else { return }
        guard let url = URL(string: "https://api.github.com/search/repositories?q=\(query)") else { return }

        AF.request(url).responseDecodable(of: RepositoryResponse.self) { response in
            switch response.result {
            case .success(let searchResponse):
                self.repositories = searchResponse.items
                
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.repositoryTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchRepository()
        return true
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = repositories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = repository.fullName
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let detailVC = DetailViewController(repository: repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
