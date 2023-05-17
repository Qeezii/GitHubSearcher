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
    private var repository: RepositoryResponse?
    private var fromFavoritesList: Bool = false
    private lazy var topConstraint: ConstraintItem = scrollView.snp.top // view.safeAreaLayoutGuide.snp.top

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let scrollStackViewContainer = UIStackView()
    private let repoFullNameLabel = UILabel()
    private let repoDescriptionLabel = UILabel()
    private let repoOwnerNameLabel = UILabel()
    private let repoOwnerEmailLabel = UILabel()
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setTitle(AppConstants.Strings.DetailScreen.favoriteButtunNormalText, for: .normal)
        button.setTitle(AppConstants.Strings.DetailScreen.favoriteBottunSelectedText, for: .selected)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        return button
    }()
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainView()
        configureScrollView()
        guard !fromFavoritesList else {
            configureUIElements()
            return
        }
        configureActivityIndicatorView()
        loadOwner()
    }

    // MARK: - Methods
    private func configureUIElements() {
        configureScrollStackViewContainer()
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
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func configureScrollStackViewContainer() {
        scrollView.addSubview(scrollStackViewContainer)
        scrollStackViewContainer.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(view)
        }
    }
    private func configureRepoFullNameLabel() {
        configureLabel(repoFullNameLabel,
                      text: AppConstants.Strings.DetailScreen.fullNameLabelText(repository?.fullName))
        scrollStackViewContainer.addSubview(repoFullNameLabel)
        repoFullNameLabel.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(AppConstants.Constraints.verticalSpacingMiddle)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureRepoDescriptionLabel() {
        topConstraint = repoFullNameLabel.snp.bottom
        guard repository?.description != nil else { return }
        configureLabel(repoDescriptionLabel,
                       text: AppConstants.Strings.DetailScreen.descriptionLabelText(repository?.description))
        scrollStackViewContainer.addSubview(repoDescriptionLabel)
        repoDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(AppConstants.Constraints.verticalSpacingMiddle)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureRepoOwnerNameLabel() {
        if repository?.description != nil {
            topConstraint = repoDescriptionLabel.snp.bottom
        }
        guard repository?.owner.name != nil else { return }
        configureLabel(repoOwnerNameLabel,
                       text: AppConstants.Strings.DetailScreen.ownerNameLabelText(repository?.owner.name))
        scrollStackViewContainer.addSubview(repoOwnerNameLabel)
        repoOwnerNameLabel.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(AppConstants.Constraints.verticalSpacingMiddle)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureRepoOwnerEmailLabel() {
        if repository?.owner.name != nil {
            topConstraint = repoOwnerNameLabel.snp.bottom
        }
        guard repository?.owner.email != nil else { return }
        configureLabel(repoOwnerEmailLabel,
                       text: AppConstants.Strings.DetailScreen.ownerEmailLabelText(repository?.owner.email))
        scrollStackViewContainer.addSubview(repoOwnerEmailLabel)
        repoOwnerEmailLabel.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(AppConstants.Constraints.verticalSpacingMiddle)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }
    private func configureFavoriteButton() {
        if repository?.owner.email != nil {
            topConstraint = repoOwnerEmailLabel.snp.bottom
        }
        favoriteButton.addTarget(self, action: #selector(favoriteButtonIsPressed), for: .touchUpInside)
        if let repository {
            favoriteButton.isSelected = CoreDataManager.shared.isFavorite(repository.id)
        }
        scrollStackViewContainer.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(AppConstants.Constraints.verticalSpacingLarge)
            $0.bottom.equalTo(scrollStackViewContainer.snp.bottom).inset(AppConstants.Constraints.verticalSpacingLarge).priority(1)
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
    private func configureLabel(_ label: UILabel, text: String?) {
        label.text = text
        label.numberOfLines = 0
        label.textColor = .black
    }
    private func loadOwner() {
        guard let repositoryUnwrap = repository else { return }
        NetworkManager.shared.fetchOwner(for: repositoryUnwrap) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let owner):
                DispatchQueue.main.async {
                    self.repository?.owner = owner
                    self.activityIndicatorView.stopAnimating()
                    self.configureUIElements()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.showErrorAlertWith(error.localizedDescription)
                }
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
    func getRepository(_ repositoryResponse: RepositoryResponse) {
        repository = repositoryResponse
    }
    func wasLoadedData(_ wasLoadedData: Bool) {
        fromFavoritesList = wasLoadedData
    }
    @objc private func favoriteButtonIsPressed() {
        guard let repository else { return }
        favoriteButton.isSelected.toggle()
        if favoriteButton.isSelected {
            CoreDataManager.shared.addFavorite(repository)
        } else {
            CoreDataManager.shared.removeFavorite(repository.id)
        }
    }
}
