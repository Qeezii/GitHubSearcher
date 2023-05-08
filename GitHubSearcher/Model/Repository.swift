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
    let id: Int
    let fullName: String
    var owner: Owner
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case owner
        case description
    }
}

struct Owner: Codable {
    let login: String
    let name: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case login
        case name
        case email
    }
}

