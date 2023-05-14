//
//  NetworkManager.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidData
}

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    /// Fetches repositories based on the provided query from the Github API.
    /// - Parameters:
    ///   - query: A `String` representing the search query.
    ///   - completion: A completion handler that takes a `Result` object which contains either a `RepositoryListResponse` object or an `Error`.
    func fetchRepositories(query: String, page: Int, completion: @escaping (Result<RepositoryListResponse, Error>) -> ()) {
        guard let url = API.apiForRepositories(query: query, page: "\(page)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                if let error {
                    completion(.failure(error))
                }
                return
            }

            do {
                let usersData = try JSONDecoder().decode(RepositoryListResponse.self, from: data)
                completion(.success(usersData))
            } catch {
                completion(.failure(NetworkError.invalidData))
            }
        }.resume()
    }

    /// Fetches the owner of a repository from the Github API
    /// - Parameters:
    ///   - repository: A `Repository` object whose owner is to be fetched.
    ///   - completion: A completion handler that takes a `Result` object which contains either an `OwnerResponse` object or an `Error`.
    func fetchOwner(for repository: RepositoryResponse, completion: @escaping (Result<OwnerResponse, Error>) -> ()) {
        let userName = repository.owner.login
        guard let url = API.apiForUser(userName: userName) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                if let error {
                    completion(.failure(error))
                }
                return
            }

            do {
                let owner = try JSONDecoder().decode(OwnerResponse.self, from: data)
                completion(.success(owner))
            } catch {
                completion(.failure(NetworkError.invalidData))
            }
        }.resume()
    }
}
