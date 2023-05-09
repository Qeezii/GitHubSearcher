//
//  NetworkManager.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case invalidURL
}

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    /// Fetches repositories based on the provided query from the Github API.
    /// - Parameters:
    ///   - query: A `String` representing the search query.
    ///   - completion: A completion handler that takes a `Result` object which contains either a `RepositoryResponse` object or an `Error`.
    func fetchRepositories(query: String, completion: @escaping (Result<RepositoryResponse, Error>) -> ()) {
        guard let url = API.apiForRepositories(query: query) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        AF.request(url)
            .validate()
            .responseDecodable(of: RepositoryResponse.self) { response in
            switch response.result {
            case .success(let searchResponse):
                completion(.success(searchResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Fetches the owner of a repository from the Github API
    /// - Parameters:
    ///   - repository: A `Repository` object whose owner is to be fetched.
    ///   - completion: A completion handler that takes a `Result` object which contains either an `Owner` object or an `Error`.
    func fetchOwner(for repository: Repository, completion: @escaping (Result<Owner, Error>) -> ()) {
        let userName = repository.owner.login
        guard let url = API.apiForUser(username: userName) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        AF.request(url)
            .validate()
            .responseDecodable(of: Owner.self) { response in
            switch response.result {
            case .success(let owner):
                completion(.success(owner))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
