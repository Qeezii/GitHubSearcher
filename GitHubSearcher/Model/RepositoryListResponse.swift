//
//  RepositoryListResponse.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import Foundation

struct RepositoryListResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [RepositoryResponse]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct RepositoryResponse: Codable {
    let id: Int
    let fullName: String
    var owner: OwnerResponse
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case owner
        case description
    }
}

struct OwnerResponse: Codable {
    let login: String
    let name: String?
    let email: String?
}

