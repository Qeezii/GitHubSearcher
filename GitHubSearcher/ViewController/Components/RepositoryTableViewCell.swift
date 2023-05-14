//
//  RepositoryTableViewCell.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 14.05.2023.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    private let repoFullName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(repoFullName)
        repoFullName.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(AppConstants.Constraints.leadingSmall)
            $0.trailing.equalToSuperview().inset(AppConstants.Constraints.trailingSmall)
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupFullName(_ fullName: String) {
        repoFullName.text = fullName
    }
}
