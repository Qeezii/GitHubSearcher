//
//  DetailViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import SnapKit

private enum Constraints: CGFloat {
    case leading = 25
    case trailing = -25
    case verticalSpacing = 50
}

final class DetailViewController: UIViewController {

    // MARK: - Properties
    var repository: Repository
    var fromFavoritesList: Bool

    // MARK: - UI Elements
    private lazy var repoFullNameLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label, text: "Repository: \(repository.fullName)")
        return label
    }()
    private lazy var repoDescriptionLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label, text: "Description: \(repository.description ?? "")")
        return label
    }()
    private lazy var repoOwnerNameLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label, text: "Owner name: \(repository.owner.name ?? "")")
        return label
    }()
    private lazy var repoOwnerEmailLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label, text: "Owner email: \(repository.owner.email ?? "")")
        return label
    }()
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add to favorites", for: .normal)
        button.setTitle("Delete from favorites", for: .selected)
        button.isSelected = CoreDataManager.shared.isFavorite(repository.id)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(favoriteButtonIsPressed), for: .touchUpInside)
        return button
    }()
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - Init
    init(repository: Repository, fromFavoritesList: Bool = false) {
        self.repository = repository
        self.fromFavoritesList = fromFavoritesList
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard !fromFavoritesList else {
            configureUIElements()
            return
        }
        configureActivityIndicatorView()
        loadOwner()
    }

    // MARK: - Methods
    private func configureUIElements() {
        configureRepoFullNameLabel()
        configureRepoDescriptionLabel()
        configureRepoOwnerNameLabel()
        configureRepoOwnerEmailLabel()
        configureFavoriteButton()
    }
    private func configureRepoFullNameLabel() {
        view.addSubview(repoFullNameLabel)
        repoFullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constraints.verticalSpacing.rawValue)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
        }
    }
    private func configureRepoDescriptionLabel() {
        guard repository.description != nil else { return }
        view.addSubview(repoDescriptionLabel)
        repoDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(repoFullNameLabel.snp.bottom).offset(Constraints.verticalSpacing.rawValue)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
        }
    }
    private func configureRepoOwnerNameLabel() {
        guard repository.owner.name != nil else { return }
        view.addSubview(repoOwnerNameLabel)
        repoOwnerNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY).offset(Constraints.verticalSpacing.rawValue)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
        }
    }
    private func configureRepoOwnerEmailLabel() {
        guard repository.owner.email != nil else { return }
        view.addSubview(repoOwnerEmailLabel)
        repoOwnerEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(repoOwnerNameLabel.snp.bottom).offset(Constraints.verticalSpacing.rawValue / 2)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
        }
    }
    private func configureFavoriteButton() {
        view.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Constraints.verticalSpacing.rawValue / 2)
            make.leading.equalToSuperview().offset(Constraints.leading.rawValue)
            make.trailing.equalToSuperview().offset(Constraints.trailing.rawValue)
            make.height.equalTo(35)
        }
    }
    private func configureActivityIndicatorView() {
        activityIndicatorView.startAnimating()
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func cofigureLabel(_ label: UILabel, text: String) {
        label.text = text
        label.numberOfLines = 0
        label.textColor = .black
    }
    private func loadOwner() {
        NetworkManager.shared.fetchOwner(for: repository) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let owner):
                strongSelf.repository.owner = owner
                strongSelf.activityIndicatorView.stopAnimating()
                strongSelf.configureUIElements()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    @objc private func favoriteButtonIsPressed() {
        favoriteButton.isSelected.toggle()
        if favoriteButton.isSelected {
            CoreDataManager.shared.addFavorite(repository)
        } else {
            CoreDataManager.shared.removeFavorite(repository.id)
        }
    }
}
