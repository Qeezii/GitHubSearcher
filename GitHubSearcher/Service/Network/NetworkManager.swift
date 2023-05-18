//
//  NetworkManager.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import Foundation
import Network

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    /// Fetches the data from the Github API
    /// - Parameters:
    ///   - mode: The fetch data mode indicating the type of data to be fetched. Available modes are:
    ///     - searchRepository: Fetches repositories based on a query and page number.
    ///     - fetchOwner: Fetches user data based on the username.
    ///   - query: The query string used for searching repositories. Default value is an empty string.
    ///   - page: The page number for paginated results. Default value is 1.
    ///   - userName: The username used for fetching user data. Default value is an empty string.
    ///   - completion: The completion handler to be called when the data fetching is complete. The handler takes a `Result` object as its parameter, which contains either the successfully decoded data or an error.
    func fetchData<T: Decodable>(mode: FetchDataMode,
                                 query: String = "",
                                 page: Int = 1,
                                 userName: String = "",
                                 completion: @escaping (Result<T, Error>) -> ()) {
        var url: URL?

        switch mode {
        case .searchRepository:
            url = API.apiForRepositories(query: query, page: "\(page)")
        case .fetchOwner:
            url = API.apiForUser(userName: userName)
        }

        guard let url else {
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
                let decodeData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodeData))
            } catch (let error) {
                completion(.failure(error))
            }
        }.resume()
    }
}
