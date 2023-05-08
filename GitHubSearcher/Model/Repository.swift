//
//  Repository.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import Foundation

struct RepositoryResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct Repository: Codable {
    let fullName: String
    let owner: Owner
    let description: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case owner
        case description
    }
}

struct Owner: Codable {
    let login: String

    enum CodingKeys: String, CodingKey {
        case login
    }
}

