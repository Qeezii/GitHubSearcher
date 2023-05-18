//
//  RepositoryTableViewCell.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 14.05.2023.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUIElements()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configureUIElements() {
        configureFullNameLabel()
    }

    private func configureFullNameLabel() {
        addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(AppConstants.Constraints.verticalSpacingSmall)
            $0.bottom.equalToSuperview().inset(AppConstants.Constraints.verticalSpacingSmall)
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingLarge)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingLarge)
        }
    }

    func setupFullName(_ fullName: String) {
        fullNameLabel.text = fullName
    }
}
