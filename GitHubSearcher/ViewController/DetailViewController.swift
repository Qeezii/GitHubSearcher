//
//  DetailViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import SnapKit
import Alamofire

class DetailViewController: UIViewController {
    var repository: Repository
    private let leadingConstraints = 25
    private let trailingConstraints = -25
    private let favoriteButton = UIButton()
    private let repoFullNameLabel = UILabel()
    private let repoDescriptionLabel = UILabel()
    private let repoOwnerNameLabel = UILabel()
    private let repoOwnerEmailLabel = UILabel()

    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadOwnerData()
        configureUIElements()
    }

    private func configureUIElements() {
        configureRepoFullNameLabel()
        configureRepoDescriptionLabel()
        configureRepoOwnerNameLabel()
        configureRepoOwnerEmailLabel()
        configureFavoriteButton()
    }
    private func configureRepoFullNameLabel() {
        repoFullNameLabel.text = "Repository: \(repository.fullName)"
        repoFullNameLabel.numberOfLines = 0
        repoFullNameLabel.textColor = .black

        view.addSubview(repoFullNameLabel)
        repoFullNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
        }
    }
    private func configureRepoDescriptionLabel() {
        guard let description = repository.description else { return }
        repoDescriptionLabel.text = "Description: \(description)"
        repoDescriptionLabel.numberOfLines = 0
        repoDescriptionLabel.textColor = .black

        view.addSubview(repoDescriptionLabel)
        repoDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(repoFullNameLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
        }
    }
    private func configureRepoOwnerNameLabel() {
        repoOwnerNameLabel.textColor = .black

        view.addSubview(repoOwnerNameLabel)
        repoOwnerNameLabel.snp.makeConstraints { make in
            make.top.equalTo(
                repository.description != nil ? repoDescriptionLabel.snp.bottom : repoFullNameLabel.snp.bottom
            ).offset(50)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
        }
    }
    private func configureRepoOwnerEmailLabel() {
        repoOwnerEmailLabel.textColor = .black

        view.addSubview(repoOwnerEmailLabel)
        repoOwnerEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(repoOwnerNameLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
        }
    }
    private func configureFavoriteButton() {
        favoriteButton.setTitle("Add to favorites", for: .normal)
        favoriteButton.setTitle("Delete from favorites", for: .selected)
        favoriteButton.backgroundColor = .blue
        favoriteButton.layer.cornerRadius = 10
        favoriteButton.addAction(UIAction(handler: { _ in
            self.favoriteButton.isSelected.toggle()
        }), for: .touchUpInside)

        view.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(repoOwnerEmailLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
            make.height.equalTo(35)
        }
    }

    private func loadOwnerData() {
        let query = repository.owner.login
        guard let url = URL(string: "https://api.github.com/users/\(query)") else { return }

        AF.request(url).responseDecodable(of: Owner.self) { response in
            switch response.result {
            case .success(let owner):
                self.repository.owner = owner
                DispatchQueue.main.async {
                    if let name = owner.name {
                        print("name:", name)
                        self.repoOwnerNameLabel.text = "Owner name: \(name)"
                    }
                    if let email = owner.email {
                        print("email:", email)
                        self.repoOwnerEmailLabel.text = "Owner e-mail \(email)"
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
