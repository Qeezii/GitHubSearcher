//
//  DetailViewController.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import SnapKit

final class DetailViewController: UIViewController {

    // MARK: - Properties
    var repository: RepositoryResponse
    var fromFavoritesList: Bool

    // MARK: - UI Elements
    private lazy var repoFullNameLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label,
                      text: AppConstants.Strings.DetailScreen.fullNameLabelText(repository.fullName))
        return label
    }()
    private lazy var repoDescriptionLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label,
                      text: AppConstants.Strings.DetailScreen.descriptionLabelText(repository.description))
        return label
    }()
    private lazy var repoOwnerNameLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label, text: "Owner name: \(repository.owner.name ?? "")")
        return label
    }()
    private lazy var repoOwnerEmailLabel: UILabel = {
        let label = UILabel()
        cofigureLabel(label,
                      text: AppConstants.Strings.DetailScreen.ownerNameLabelText(repository.owner.name))
        return label
    }()
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setTitle(AppConstants.Strings.DetailScreen.favoriteButtunNormalText, for: .normal)
        button.setTitle(AppConstants.Strings.DetailScreen.favoriteBottunSelectedText, for: .selected)
        button.isSelected = CoreDataManager.shared.isFavorite(repository.id)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(favoriteButtonIsPressed), for: .touchUpInside)
        return button
    }()
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - Init
    init(repository: RepositoryResponse, fromFavoritesList: Bool = false) {
        self.repository = repository
        self.fromFavoritesList = fromFavoritesList
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        // TODO: сделать алерт
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        guard !fromFavoritesList else {
            configureUIElements()
            return
        }
        configureActivityIndicatorView()
        loadOwner()
    }

    // MARK: - Methods
    private func configureUIElements() {
        configureMainView()
        configureRepoFullNameLabel()
        configureRepoDescriptionLabel()
        configureRepoOwnerNameLabel()
        configureRepoOwnerEmailLabel()
        configureFavoriteButton()
    }
    private func configureMainView() {
        view.backgroundColor = .white
        title = AppConstants.Strings.DetailScreen.title
    }
    private func configureRepoFullNameLabel() {
        view.addSubview(repoFullNameLabel)
        repoFullNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureRepoDescriptionLabel() {
        guard repository.description != nil else { return }
        view.addSubview(repoDescriptionLabel)
        repoDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(repoFullNameLabel.snp.bottom).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureRepoOwnerNameLabel() {
        guard repository.owner.name != nil else { return }
        view.addSubview(repoOwnerNameLabel)
        repoOwnerNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.snp.centerY).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureRepoOwnerEmailLabel() {
        guard repository.owner.email != nil else { return }
        view.addSubview(repoOwnerEmailLabel)
        repoOwnerEmailLabel.snp.makeConstraints {
            $0.top.equalTo(repoOwnerNameLabel.snp.bottom).offset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureFavoriteButton() {
        view.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(AppConstants.Constraints.verticalSpacing)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
            $0.height.equalTo(AppConstants.Constraints.height)
        }
    }
    private func configureActivityIndicatorView() {
        activityIndicatorView.startAnimating()
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
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
                DispatchQueue.main.async {
                    strongSelf.activityIndicatorView.stopAnimating()
                    strongSelf.configureUIElements()
                }
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
