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

    private let apiRepositories = "https://api.github.com/search/repositories?q="
    private let apiUsers = "https://api.github.com/users/"

    private init() {}

    func fetchRepository(query: String, complition: @escaping (Result<RepositoryResponse, Error>) -> ()) {
        guard let url = URL(string: "\(apiRepositories)\(query)") else {
            complition(.failure(NetworkError.invalidURL))
            return
        }

        AF.request(url).responseDecodable(of: RepositoryResponse.self) { response in
            switch response.result {
            case .success(let searchResponse):
                complition(.success(searchResponse))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    func fetchOwnerData(for repository: Repository, completion: @escaping (Result<Owner, Error>) -> ()) {
        let query = repository.owner.login
        guard let url = URL(string: "\(apiUsers)\(query)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        AF.request(url).responseDecodable(of: Owner.self) { response in
            switch response.result {
            case .success(let owner):
                completion(.success(owner))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
