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

    private var ownerName: String? {
        didSet {
            if let name = ownerName {
                repoOwnerNameLabel.text = "Owner name: \(name)"
            }
        }
    }
    private var ownerEmail: String? {
        didSet {
            if let email = ownerEmail {
                repoOwnerEmailLabel.text = "Owner email: \(email)"
            }
        }
    }

    private let leadingConstraints = 25
    private let trailingConstraints = -25
    private let spacingConstraints = 50

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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
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
            make.top.equalTo(repoFullNameLabel.snp.bottom).offset(spacingConstraints)
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
            make.top.equalTo(repoOwnerNameLabel.snp.bottom).offset(spacingConstraints / 2)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
        }
    }
    private func configureFavoriteButton() {
        favoriteButton.setTitle("Add to favorites", for: .normal)
        favoriteButton.setTitle("Delete from favorites", for: .selected)
        favoriteButton.isSelected = CoreDataManager.shared.isFavorite(repository.id)
        favoriteButton.backgroundColor = .blue
        favoriteButton.layer.cornerRadius = 10
        favoriteButton.addAction(UIAction(handler: { _ in
            self.favoriteButton.isSelected.toggle()
            if self.favoriteButton.isSelected {
                CoreDataManager.shared.addFavorite(self.repository)
            } else {
                CoreDataManager.shared.removeFavorite(self.repository.id)
            }
        }), for: .touchUpInside)

        view.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(repoOwnerEmailLabel.snp.bottom).offset(spacingConstraints)
            make.leading.equalToSuperview().offset(leadingConstraints)
            make.trailing.equalToSuperview().offset(trailingConstraints)
            make.height.equalTo(35)
        }
    }

    private func loadOwnerData() {
        NetworkManager.shared.fetchOwnerData(for: repository) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let owner):
                strongSelf.repository.owner = owner
                DispatchQueue.main.async {
                    strongSelf.ownerName = owner.name
                    strongSelf.ownerEmail = owner.email
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
